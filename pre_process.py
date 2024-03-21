import re
import chardet

# Função para extrair procedures do arquivo SQL com base na expressão regular aprimorada
def extract_procedures(sql_text):
    # Ajuste esta expressão regular conforme necessário
    pattern = re.compile(r'(?is)(BEGIN\s+.*?;\s*END;)')
    procedures = pattern.findall(sql_text)
    return procedures

# Exemplo de uso
#sql_text = "./SP/fc_AS_homologacaor.sql"
#sql_text = "./SP/pr_AS_homologacaor.sql"
sql_text = "./SP/foobar.sql"
"""
Aqui você colocaria o seu texto SQL grande, como o exemplo de procedure fornecido.
"""
def read_file(sql_text):
    with open(sql_text, 'rb') as file:
        sql_content = file.read()
    encoding = chardet.detect(sql_content)['encoding']
    print(f"Detected encoding: {encoding}")
        
    return sql_content.decode(encoding)

sql_content = read_file(sql_text)
procedures = extract_procedures(sql_content)
for i, proc in enumerate(procedures, start=1):
    print(f"Procedure {i}: {proc}")

##########################

import logging
import sys
import os
from File_Handler import FileHandler
from ProcedureExtractor import ProcedureExtractor
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(name)s - [%(filename)s:%(lineno)d] - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',)
logger = logging.getLogger()

class DescriptionGenerator:
    def __init__(self, api_key, system, system_content, model="gpt-4-turbo-preview", temperature=0.1):
        self.api_key = api_key
        self.system = system
        self.system_content = system_content
        self.model = model
        self.temperature = temperature

    def generate_description(self, prompt, prompt_content, accumulated_content=""):
        try:
            chat = ChatOpenAI(
                temperature=self.temperature, 
                openai_api_key=self.api_key, 
                model=self.model, 
                verbose=True)
            messages = [
                SystemMessage(content=self.system),
                SystemMessage(content=self.system_content),
                HumanMessage(content=prompt)
            ]
            if accumulated_content:
                messages.append(SystemMessage(content=accumulated_content))

            messages.append(HumanMessage(content=prompt_content))
            response = chat.invoke(messages)
            r = chat.batch

            new_description = response.content
            updated_accumulated_content = accumulated_content + "\n" + new_description

            return new_description, updated_accumulated_content
        except Exception as e:
            sys.exit(f"Error generating description: {e}")

class DocumentationGenerator:
    def __init__(self, config):
        self.file_handler = FileHandler()
        self.extractor = ProcedureExtractor()
        system_content = self.file_handler.read_file(config['system_file_path'])
        self.generator = DescriptionGenerator(config['api_key'], config['system'], system_content)

    def generate_documentation(self, config):
        for prompt_file_name in os.listdir(config['prompt_directory']):
            prompt_file_path = os.path.join(config['prompt_directory'], prompt_file_name)
            prompt_content = self.file_handler.read_file(prompt_file_path)
            
            logger.info(f"Generating documentation for procedure {prompt_file_name}")
            
            
            description = self.generator.generate_description(config['prompt'], prompt_content)
            
            #procedures = self.extractor.extract_procedures(prompt_content)
            #accumulated_documentation = ""

            #batch_size = 50
            #for i in range(0, len(procedures), batch_size):
            #    batch = procedures[i:i+batch_size]
            #    for p, procedure_content in enumerate(batch):
            #        logger.info(f"Generating documentation for procedure {i + p + 1} in file {prompt_file_path}...")
            #        new_description, accumulated_documentation = self.generator.generate_description(
            #            config['prompt'], procedure_content, accumulated_documentation)
            ########
            # for i, procedure_content in enumerate(procedures):
            #     logger.info(f"Generating documentation file {prompt_file_path} for procedure {i+1}...")
            #     new_description, accumulated_documentation = self.generator.generate_description(
            #         config['prompt'], procedure_content, accumulated_documentation)
            #if accumulated_documentation:
            #    output_base_path = os.path.join('output', os.path.splitext(prompt_file_name)[0])
            #    self.file_handler.save_description(output_base_path, config['output_file_name'], accumulated_documentation)
            #    logger.info(f"Documentation saved to {output_base_path}.{config['output_file_name']}")
            #else:
            #    logger.info("No documentation generated.")