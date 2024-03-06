import sys
import re

# Extracts procedures from SQL text
class ProcedureExtractor:
    @staticmethod
    def extract_procedures(sql_text):
        try:
            pattern = re.compile(r'(?is)(BEGIN\s+.*?;\s*END;)')
            return pattern.findall(sql_text)
        except Exception as e:
            sys.exit(f"Error extracting procedures from SQL: {e}")