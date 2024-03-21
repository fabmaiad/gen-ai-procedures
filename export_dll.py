import oracledb

# Conexão ao banco de dados Oracle
db = oracledb.connect("T2400020/JWOE8255@10.10.0.19:1521/AS")
cursor = db.cursor()

# Lista de nomes de procedimentos
proc_names = ['corteconvenio', # OK
              'pr_envia_itf_cartao', # OK
              'pr_envia_itf_transacao', # OK
              'pr_equaliza_venc_convenio', # OK
              'pr_itf_agn_cor', # OK
              'PR_ITF_10',
              'pr_envia_itf_transacaomc',
              'PR_ITF_ANTECIPACAO_ARARAS',
              'PR_CORRIGE_SEGURO',
              'PR_ENVIA_ITF_SEGURO'
            ]

# Iterar sobre a lista de nomes de procedimentos
for proc_name in proc_names:
    # Executar a consulta para obter o DDL do procedimento atual
    cursor.execute(f"SELECT DBMS_METADATA.GET_DDL('PROCEDURE', '{proc_name}', 'UNIKVP') FROM DUAL")
    c = cursor.fetchall()
    
    # Verificar se o DDL foi recuperado com sucesso
    if c and c[0] and c[0][0]:
        # Escrever o DDL em um arquivo, nomeando o arquivo após o procedimento
        file_name = f'{proc_name}_DDL.sql'
        with open(file_name, 'w') as sample:
            print(c[0][0], file=sample)
            print(f'DDL for {proc_name} written to {file_name}')
    else:
        print(f'No DDL found for {proc_name}')

# Fechar o cursor e a conexão
cursor.close()
db.close()




 #'corteconvenio','pr_envia_itf_cartao', 'pr_envia_itf_transacao', 'pr_equaliza_venc_convenio', 'pr_itf_agn_cor', 'PR_ITF_10', 'pr_envia_itf_transacaomc','PR_ITF_ANTECIPACAO_ARARAS', 'PR_CORRIGE_SEGURO', 'PR_ENVIA_ITF_SEGURO'