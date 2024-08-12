import 'dart:convert';
import 'dart:io';

import 'package:app_gemini/interfaces/QuestionInterface.dart';
import 'package:app_gemini/services/ErrorService.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_community/langchain_community.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  final String? apiKey = dotenv.env['API_KEY'];
  final FirebaseDatabase db = FirebaseDatabase();
  final Errorservice err = Errorservice();


  Future<String> transcriptDocument(File file, String url) async {
    if (apiKey == null) {
      print('No \$API_KEY environment variable');
      return '';
    }

    String mimeType = lookupMimeType(file.path)!;
    final fileBytes = await file.readAsBytes();

    String newurl = url.replaceAll('%2F', '*75');

    final prompt = """
    Transcribe the following file into Markdown format unless
    if the file is an image and it hasn't text, generate a title and description, and below it the URL: $newurl in this format:
    title
    ![description]($newurl)
    if the file isn't an image only transcribe it into Markdown format without include the previous format of url.
    """;

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, fileBytes),
      ])
    ];
    final response = await model.generateContent(content);

    return  response.text!;

  }

  Future<List<Question>> generateQuestions(String topicId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      String filePath = 'users/$userId/topics/$topicId/transcript.txt';
      File file = await db.getDocumentFromFirebase(filePath);

      String mimeType = lookupMimeType(file.path)!;
      final fileBytes = await file.readAsBytes();

      final prompt = """
        Dame 5 preguntas aleatorias basadas en este documento, las preguntas deben 
        ser del tipo de alternativa y respuesta abierta, además deben tener el siguiente formato JSON obligatorio:
        [
          {
            question: ,
            options: ["opcion",],
            type: "multipleChoice" o "open",
            answer: 
          }
        ]
      """;

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);
      final content = [
        Content.multi([
          DataPart(mimeType, fileBytes),
          TextPart(prompt),
        ])
      ];
      final response = await model.generateContent(content);
      String responseText = response.text!;

      if (responseText.startsWith('```json')) {
        responseText = responseText.replaceAll('```json', '').replaceAll('```', '');
      }
      final List<dynamic> questionsJson = json.decode(responseText);

      return questionsJson.map((json) =>
          Question.fromJson(json as Map<String, dynamic>)).toList();
    }
    catch(e){
      print(e);
      err.writeError(e.toString());
      return [];
    }

  }

  Future<bool> evaluateAnswer(String question, String answer, String correctAnswer) async{
    print(question +'\n' + answer+'\n' + correctAnswer);
    final prompt = """Con esta pregunta: $question y su respuesta: $correctAnswer 
    Evalua la respuesta del usuario: $answer, si la respuesta es aproximada o parecida calficalo bien, dame solo true o false en este objeto JSON:
    {
      isCorrect = true o false,
    }""";

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);
    final content = [
      Content.multi([
        TextPart(prompt),
      ])
    ];
    try {
      final response = await model.generateContent(content);
      String responseText = response.text!;
      if (responseText.startsWith('```json')) {
        responseText =
            responseText.replaceAll('```json', '').replaceAll('```', '');
      }

      final dynamic questionsJson = json.decode(responseText);
      print(questionsJson);
      return questionsJson.isCorrect;
    } catch(e) {
      return false;
    }
  }

  Future<RetrievalQAChain> initRag () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final locale = prefs.getString('locale');
    print(locale);
    var apiKey = dotenv.env['API_KEY'];

    try {
      //RAG
      String combinedContent = await db.combineTranscripts(userId!);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/combined_transcripts.txt');
      await tempFile.writeAsString(combinedContent);

      final loader = TextLoader(tempFile.path);
      final documents = await loader.load();

      const textSplitter = RecursiveCharacterTextSplitter(
        chunkSize: 800,
        chunkOverlap: 0,
      );

      final docs = textSplitter.splitDocuments(documents);

      final embeddings = GoogleGenerativeAIEmbeddings(
        apiKey: apiKey,
      );

      final docSearch = await MemoryVectorStore.fromDocuments(
        documents: docs,
        embeddings: embeddings,
      );

      final chatModel = ChatGoogleGenerativeAI(apiKey: apiKey);
      final docPrompt = ChatPromptTemplate.fromTemplate(

          '''
          Eres un asistente que ayuda al usuario a repasar temas en base a este contexto: {context}
          Question: {question} 
          responde al usuario en este idioma: ${locale=='es_ES'? "Español": "English"}
          '''
      );

      final qaChain = LLMChain(llm: chatModel, prompt: docPrompt);

      final finalQAChain = StuffDocumentsChain(
        llmChain: qaChain,
      );
      final retrievalQA = RetrievalQAChain(
        retriever: docSearch.asRetriever(),
        combineDocumentsChain: finalQAChain,
      );

      return retrievalQA;
    } catch (error) {
      throw 'Error loading RAG \n$error';
    }
  }

  Future<String> ragResponse(RetrievalQAChain retrievalQA,String query) async {
    try {
      final res = await retrievalQA(query);
      return res['result'];

    } catch(e){
     print(e);
     return '';
    }
  }

  Future<String> chatResponse(String answer, String context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('locale');

    final prompt = """
    Eres un asistente que ayuda al usuario a repasar temas en base a este contexto:
    ${context}
    responde esta pregunta: ${answer} en este lenguage ${locale=='es_ES'? "Español": "English"}""";

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);
    final content = [
      Content.multi([
        TextPart(prompt),
      ])
    ];

    try {
      final response = await model.generateContent(content);
      return response.text!;
    } catch(e) {
      return '';
    }
  }

}