import {setGlobalOptions} from "firebase-functions";
import {onCall, HttpsError} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { defineSecret } from "firebase-functions/params";
import OpenAI from "openai";

const OPENAIKEY = defineSecret("OPENAI_API_KEY")

setGlobalOptions({ maxInstances: 10 });

export const helloDeveloper = onCall((request) => {
  logger.info("Hello Developer!");
  console.log("Hello, you must be a developer!");
  return "Hello dev, this is me from Firebase!";
});

export const generateOpenAIText = onCall(
  { secrets: [OPENAIKEY] },
  async (request) => {

  const messages = request.data.messages;

  // Check that messages are injected
  if (!messages) {
    throw new HttpsError("invalid-argument", "No messages provided in the request.");
  }

  // Set up query
  const query = {
    model: "gpt-3.5-turbo",
    messages: messages
  }

  // Set up OpenAI 
  const openai = new OpenAI({ 
    apiKey: OPENAIKEY.value()
  });

  const response = await openai.chat.completions.create(query);

  const chatResponse = response.choices[0].message;

  if (!chatResponse) {
    throw new HttpsError("data-loss", "Invalid response from OpenAI.");
  }

  return chatResponse
});

export const generateOpenAIImage = onCall(
  { secrets: [OPENAIKEY] },
  async (request) => {

  const input = request.data.input;

  // Check that messages are injected
  if (!input) {
    throw new HttpsError("invalid-argument", "No input provided in the request.");
  }

  // Set up query
  const query: OpenAI.Images.ImageGenerateParams = {
    prompt: input,
    n: 1,
    size: "512x512",
    response_format: "b64_json"
  }

  // Set up OpenAI 
  const openai = new OpenAI({ 
    apiKey: OPENAIKEY.value()
  });

  const response = await openai.images.generate(query);

  if (!response.data || !Array.isArray(response.data) || !response.data[0]?.b64_json) {
    throw new HttpsError('data-loss', 'Invalid response from OpenAI');
  }

  const b64Json = response.data[0].b64_json;

  if (!b64Json) {
    throw new HttpsError("data-loss", "Invalid response from OpenAI.");
  }

  return b64Json
});
