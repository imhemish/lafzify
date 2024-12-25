import google.generativeai as genai
from .exceptions import EmptyInput
from typing import List, Dict
from os import environ
from ..settings import settings
from pydantic import Field, Json, BaseModel, conlist

class GeminiResponse(BaseModel):
    contents: Dict[int | None, str]

class GeminiRequest(BaseModel):
    input: str
    char_limits: List[int]
    include_emojis: bool
    
class GeminiJson(BaseModel):
    gemini_returned_json: Json[GeminiResponse]

class GeminiSource():
    model: genai.GenerativeModel
    
    def build_prompt(self, input: str, char_limits: List[int], include_emojis: bool = True) -> str:
        if input == "":
            raise EmptyInput()
        prompt: str = ""
        prompt += "Write content about the following:\n"
        prompt += (input+"\n")
        prompt += f"Generate {len(char_limits)} content(s) with character limit(s) {",".join(map(str, char_limits))}\n"
        prompt += "If there is -1 character limit, it means you can write bigger content for it\n"
        prompt += "You have to strictly follow the limit, you can't even include 1 character more than the given\n"
        prompt += "\n"
        
        prompt += "Provide it in json format, use markdown within it\n"
        prompt += "You can also include newlines within it via backslash n\n"
        prompt += "Convert any None to Null because it is json\n"
        if not include_emojis:
            prompt += "Do not include emojis\n"
        else:
            prompt += "Include emojis\n"
        prompt += "In the JSON response, use a 'contents' key in toplevel and provide the contents as a map, for key use character limit, and value as the actual content'\n"
        prompt += """Sample JSON response:
        {
            "contents": {
                "400": "blah blah (less than 400 words)",
                "-1": "blah blah (very detailed)",
                "600": "blah blah (less than 600 words)"
            }
        }
        """
        
        return prompt
    
    def __init__(self, key: str, sys_instructs: str | None = None, model_name: str = "gemini-1.5-flash"):
        genai.configure(api_key=key)
        self.model = genai.GenerativeModel(model_name, system_instruction=sys_instructs)
    
    def get_contents(self, geminiRequest: GeminiRequest) -> GeminiResponse:
        prompt = self.build_prompt(input=geminiRequest.input, char_limits=geminiRequest.char_limits, include_emojis=geminiRequest.include_emojis)
        r = self.model.generate_content(prompt)
        json_text = r.text.replace("```json\n", '').replace("\n```", '')
        return GeminiJson(gemini_returned_json=json_text).gemini_returned_json