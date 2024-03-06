CREATE OR REPLACE PROCEDURE UNIKVP.pr_envia_itf_cartao AS
--declare

v_qtdetrs INTEGER := 0;

CURSOR ITFTRANSACAO IS
SELECT   /*+ parallel(4) */
         TGCN_CLNT_COD_CLI
        ,TGCN_COD_CTO_FUN
        ,TGCN_COD_CTA_FUN
        ,TGCN_SITUACAO
        ,TGCN_MTV_BLQ_CAN
        ,TGCN_TIP_CTO
        ,TGCN_TIP_ACAO
        ,TGCN_DTA_CDS
        ,TGCN_COD_CTO_DEP
        , NVL(TGCN_FLFN_COD_FIL_CLI,'0000') AS TGCN_FLFN_COD_FIL_CLI
        -- ,Decode(TGCN_FLFN_COD_FIL_CLI,'0000',NULL,TGCN_FLFN_COD_FIL_CLI) AS TGCN_FLFN_COD_FIL_CLI
        ,TGCN_NOME
        ,f_tira_caracter(TGCN_CPF) AS TGCN_CPF
        ,Nvl(TGCN_MATRICULA,' ') AS TGCN_MATRICULA
        ,TGCN_COD_BNC
        ,TGCN_COD_AGC
        ,TGCN_CONTACORRE
        ,TGCN_CCUSTO
        ,TGCN_DES_CCUSTO
        ,TGCN_DAT_NAS
        ,TGCN_CARGO_FUN
        ,TGCN_DAT_ADS
        ,Decode(TGCN_EDR,'-',NULL,TGCN_EDR) AS TGCN_EDR
        --, TGCN_NRO_EDR
         ,Decode(TGCN_NRO_EDR,0,NULL,TGCN_NRO_EDR) AS TGCN_NRO_EDR
        ,Decode(TGCN_BRR,'-',NULL,TGCN_BRR) AS TGCN_BRR
        --, TGCN_CEP
         ,Decode(TGCN_CEP,'00000000',NULL,TGCN_CEP) AS TGCN_CEP
        ,Decode(TGCN_CID,'-',NULL,TGCN_CID) AS TGCN_CID
        ,Decode(TGCN_UF,'-',NULL,TGCN_UF) AS TGCN_UF
        --,TGCN_EML
        ,SubStr(TGCN_EML,1,50) AS TGCN_EML
        ,Decode(TGCN_TEL,'00000000',NULL,TGCN_TEL) AS TGCN_TEL
        ,Decode(TGCN_DDD,'000'     ,NULL,TGCN_DDD) AS TGCN_DDD
        ,TGCN_COD_MSC
        ,TGCN_COD_PLU
        ,TGCN_LMT_POS
        ,TGCN_LMT_PRE
        ,TGCN_LMT_RSC
        ,TGCN_GRP_COD
        ,'zzzz' AS TGCN_SNH
        ,TGCN_DAT_PRC
        ,TGCN_TIP_OCR
        ,TGCN_MTV_ERRO
        ,TGCN_REDUCAO_LIMITE
        ,IDITF_CARTAO_NEUS
FROM  (
SELECT CTPF.IDLOJA                                                                AS TGCN_CLNT_COD_CLI,
       CL.NUMEROMANUAL                                                            AS TGCN_COD_CTO_FUN,
       Nvl(CTPF.CAMPOAUX2,CL.NUMEROMANUAL)                                        AS TGCN_COD_CTA_FUN,
       Decode(CTPF.STATUS_CLIENTE, 'A', Decode(CL.STATUS, 'V', 'A', 'B'), 'B')    AS TGCN_SITUACAO,
       CASE ITF.OPERACAO
           WHEN 'C' THEN
               FN_MOTIVOBLOQUEIO ('C', ITF.IDCLIENTEPESSOAFISICA, ITF.TABELA)
           WHEN 'B' THEN
               FN_MOTIVOBLOQUEIO ('B', ITF.IDCARTAOLOJA, ITF.TABELA)
           ELSE NULL
       END                                                                        AS TGCN_MTV_BLQ_CAN,
       'F'                                                                        AS TGCN_TIP_CTO,
       Decode(ITF.OPERACAO, 'I', 1,
                            'A', 2,
                            'F', 2,
                            'C', 3,
                            'R', 4,
                            'E', 5,
                            'G', 6,
                            'M', 7,
                            'B', 8,
                            'D', Decode(CTPF.STATUS_CLIENTE, 'A', Decode(CL.STATUS, 'V', 9, 2), 2),
                            'P', Decode(CTPF.STATUS_CLIENTE, 'A', Decode(CL.STATUS, 'V', 9, 2), 2),
                            'L',10,
                            2)                                                    AS TGCN_TIP_ACAO,
       SYSDATE                                                                    AS TGCN_DTA_CDS,
       NULL                                                                       AS TGCN_COD_CTO_DEP,
--       (SELECT SubStr(DESCRICAO,1,14) FROM T_SETOR WHERE IDSETOR = CTPF.IDSETOR)  AS TGCN_FLFN_COD_FIL_CLI,
       FN_RETORNA_FILIAL(CTPF.IDLOJA, CTPF.IDFILIALFUNCIONARIO) AS TGCN_FLFN_COD_FIL_CLI,
       F_ABV_NOME_ALL(Nvl(P.NOME,'SEM NOME'), 35)                                 AS TGCN_NOME,
       PF.CPF                                                                     AS TGCN_CPF,
       CTPF.CAMPOAUX1                                                             AS TGCN_MATRICULA,
       B.CODIGO                                                                   AS TGCN_COD_BNC,
        F_LIMPA_CARACTER(CTPF.AGENCIA)                                                               AS TGCN_COD_AGC,
        --- CTPF.AGENCIA                                                              AS TGCN_COD_AGC,
       CTPF.CONTA                                                                 AS TGCN_CONTACORRE,
       CTPF.CAMPOAUX4                                                             AS TGCN_CCUSTO,
       CTPF.CAMPOAUX5                                                             AS TGCN_DES_CCUSTO,
       PF.DATANASCIMENTO                                                          AS TGCN_DAT_NAS,
       NULL                                                                       AS TGCN_CARGO_FUN,
       CTPF.dataadmissao                                                          AS TGCN_DAT_ADS,
       F_ABV_NOME_ALL(E.LOGRADOURO, 50)                                           AS TGCN_EDR,
       --E.NUMERO      AS TGCN_NRO_EDR,
        CASE WHEN F_LIMPA_CARACTER(E.NUMERO) IS NULL THEN 0 ELSE TO_NUMBER(SUBSTR(F_LIMPA_CARACTER(E.NUMERO), 1, 5)) END AS TGCN_NRO_EDR,
       F_ABV_NOME_ALL(E.BAIRRO, 30)                                               AS TGCN_BRR,
        --E.CEP AS TGCN_CEP,
       F_LIMPA_CARACTER(E.CEP)                                                     AS TGCN_CEP,
       F_ABV_NOME_ALL(E.LOCALIDADE, 30)                                           AS TGCN_CID,
       E.UF                                                                       AS TGCN_UF,
       PF.EMAIL                                                                   AS TGCN_EML,
       (SELECT CASE WHEN F_LIMPA_CARACTER(NUMERO) IS NULL THEN '0' ELSE SUBSTR(F_LIMPA_CARACTER(E.NUMERO), 1, 8) END
        --(SELECT NUMERO
        FROM   T_TELEFONE
        WHERE  IDTELEFONE = (SELECT Max(IDTELEFONE)
                             FROM   T_TELEFONE_PESSOA
                             WHERE  IDPESSOA = P.IDPESSOA))                       AS TGCN_TEL,
      -- (SELECT F_LIMPA_CARACTER(AREA)
       (SELECT CASE WHEN F_LIMPA_CARACTER(AREA) IS NULL THEN '0' ELSE F_LIMPA_CARACTER(AREA) END
        FROM   T_TELEFONE
        WHERE  IDTELEFONE = (SELECT Max(IDTELEFONE)
                             FROM   T_TELEFONE_PESSOA
                             WHERE  IDPESSOA = P.IDPESSOA))                      AS TGCN_DDD,
       (SELECT Max(IDMASCARACARTAOPRESENTE)
        FROM   T_MULTICASHPRESENTE
        WHERE  IDCARTAOLOJA = CL.IDCARTAOLOJA)                                    AS TGCN_COD_MSC,
       (SELECT PLU
        FROM   T_MULTICASHPRESENTE     MP,
               T_MASCARACARTAOPRESENTE MC
        WHERE  MP.IDCARTAOLOJA = CL.IDCARTAOLOJA
        AND    MC.IDMASCARACARTAOPRESENTE = MP.IDMASCARACARTAOPRESENTE)           AS TGCN_COD_PLU,
        LIMITEAPLICADO/100                                                         AS TGCN_LMT_POS,
       Nvl((SELECT Sum(VALORPAGO)
            FROM   T_PAGAMENTO
            WHERE  --IDFATURA = F.IDFATURA
            IDFATURA = (SELECT IDFATURA FROM T_FATURA WHERE IDCLIENTETITULARPESSOAFISICA = CTPF.IDCLIENTETITULARPESSOAFISICA AND ATIVA = 'S')
            AND    STATUS   = 'N'
            AND    MEIOTRANSACAO NOT IN ('S','E','C')),0)
       +
       Nvl((SELECT Sum(VALOR)*(-1)
            FROM   T_LANCAMENTOAJUSTE
            WHERE  IDCLIENTETITULARPESSOAFISICA = CTPF.IDCLIENTETITULARPESSOAFISICA
            AND    FATURADO   = 'N'
            AND    IDTIPOLANCAMENTOAJUSTE = 7),0)                                 AS TGCN_LMT_PRE,
       0                                                                          AS TGCN_LMT_RSC,
       1                                                                          AS TGCN_GRP_COD,
       'zzzz'                                                                     AS TGCN_SNH,
       NULL                                                                       AS TGCN_DAT_PRC,
       NULL                                                                       AS TGCN_TIP_OCR,
       NULL                                                                       AS TGCN_MTV_ERRO,
       REDUCAOLIMITEMP                                                            AS TGCN_REDUCAO_LIMITE,
       IDITF_CARTAO_NEUS
FROM   T_ITF_CARTAO_NEUS                       ITF
       INNER JOIN T_CARTAOLOJA                 CL   ON (CL.IDCARTAOLOJA                     = ITF.IDCARTAOLOJA)
       INNER JOIN T_CLIENTETITULARPESSOAFISICA CTPF ON (CTPF.IDCLIENTETITULARPESSOAFISICA   = ITF.IDCLIENTEPESSOAFISICA)
       INNER JOIN T_LIMITECREDITO              LC   ON (LC.IDCLIENTETITULARPESSOAFISICA     = CTPF.IDCLIENTETITULARPESSOAFISICA
                                                    AND LC.IDCLIENTETITULARPESSOAFISICA     = ITF.IDCLIENTEPESSOAFISICA)
       INNER JOIN T_ENDERECO                   E    ON (E.IDENDERECO                        = CTPF.IDENDERECORESIDENCIAL)
       INNER JOIN T_PESSOA                     P    ON (P.IDPESSOA                          = CTPF.IDCLIENTETITULARPESSOAFISICA
                                                    AND P.IDPESSOA                          = ITF.IDCLIENTEPESSOAFISICA)
       INNER JOIN T_PESSOAFISICA               PF   ON (PF.IDPESSOAFISICA                   = P.IDPESSOA
                                                    AND PF.IDPESSOAFISICA                   = ITF.IDCLIENTEPESSOAFISICA)
       LEFT JOIN T_BANCO                      B    ON (B.IDBANCO                            = CTPF.IDBANCO)
WHERE  ITF.ENVIADO = 'N' AND ITF.OPERACAO <> 'L'
AND    Nvl(ITF.IDCLIENTEPESSOAFISICA,-1) > -1
AND    iditf_cartao_neus >= 179398972
AND    lc.idlimiteadicional is null
UNION ALL
SELECT CTPF.IDLOJA                                                                AS TGCN_CLNT_COD_CLI,
       CT.NUMEROMANUAL                                                            AS TGCN_COD_CTO_FUN,
       Nvl(CTPF.CAMPOAUX2,CL.NUMEROMANUAL)                                        AS TGCN_COD_CTA_FUN,
       Decode(CTPF.STATUS_CLIENTE, 'A', Decode(CL.STATUS, 'V', 'A', 'B'), 'B')    AS TGCN_SITUACAO,
       CASE ITF.OPERACAO
           WHEN 'C' THEN
               FN_MOTIVOBLOQUEIO ('C', ITF.IDCLIENTEPESSOAFISICA, ITF.TABELA)
           WHEN 'B' THEN
               FN_MOTIVOBLOQUEIO ('B', ITF.IDCARTAOLOJA, ITF.TABELA)
           ELSE NULL
       END                                                                        AS TGCN_MTV_BLQ_CAN,
       'D'                                                                        AS TGCN_TIP_CTO,
       Decode(ITF.OPERACAO, 'I', 1,
                            'A', 2,
                            'F', 2,
                            'C', 3,
                            'R', 4,
                            'E', 5,
                            'G', 6,
                            'M', 7,
                            'B', 8,
                            'D', Decode(CTPF.STATUS_CLIENTE, 'A', Decode(CL.STATUS, 'V', 9, 2), 2),
                            'P', Decode(CTPF.STATUS_CLIENTE, 'A', Decode(CL.STATUS, 'V', 9, 2), 2),
                            'L',10,
                            2)                                                    AS TGCN_TIP_ACAO,
       SYSDATE                                                                    AS TGCN_DTA_CDS,
       CL.NUMEROMANUAL                                                            AS TGCN_COD_CTO_DEP,
---       (SELECT SubStr(DESCRICAO,1,14) FROM T_SETOR WHERE IDSETOR = CTPF.IDSETOR)  AS TGCN_FLFN_COD_FIL_CLI,
       FN_RETORNA_FILIAL(CTPF.IDLOJA, CTPF.IDFILIALFUNCIONARIO) AS TGCN_FLFN_COD_FIL_CLI,
       F_ABV_NOME_ALL(Nvl(CDPF.NOME_CARTAO,'SEM NOME'), 35)                       AS TGCN_NOME,
       PF.CPF                                                                     AS TGCN_CPF,
       CTPF.CAMPOAUX1                                                             AS TGCN_MATRICULA,
       B.CODIGO                                                                   AS TGCN_COD_BNC,
        F_LIMPA_CARACTER(CTPF.AGENCIA)                                                               AS TGCN_COD_AGC,
       --- CTPF.AGENCIA                                                               AS TGCN_COD_AGC,
       CTPF.CONTA                                                                 AS TGCN_CONTACORRE,
       CTPF.CAMPOAUX4                                                             AS TGCN_CCUSTO,
       CTPF.CAMPOAUX5                                                             AS TGCN_DES_CCUSTO,
       PF.DATANASCIMENTO                                                          AS TGCN_DAT_NAS,
       NULL                                                                       AS TGCN_CARGO_FUN,
       CTPF.dataadmissao                                                          AS TGCN_DAT_ADS,
       F_ABV_NOME_ALL(E.LOGRADOURO, 50)                                           AS TGCN_EDR,
       --E.NUMERO      AS TGCN_NRO_EDR,
       CASE WHEN F_LIMPA_CARACTER(E.NUMERO) IS NULL THEN 0 ELSE TO_NUMBER(SUBSTR(F_LIMPA_CARACTER(E.NUMERO), 1, 5)) END AS TGCN_NRO_EDR,
       F_ABV_NOME_ALL(E.BAIRRO, 30)                                               AS TGCN_BRR,
       --E.CEP   AS TGCN_CEP,
       F_LIMPA_CARACTER(E.CEP)                                                     AS TGCN_CEP,
       F_ABV_NOME_ALL(E.LOCALIDADE, 30)                                           AS TGCN_CID,
       E.UF                                                                       AS TGCN_UF,
       PF.EMAIL                                                                   AS TGCN_EML,
        (SELECT CASE WHEN F_LIMPA_CARACTER(NUMERO) IS NULL THEN '0' ELSE SUBSTR(F_LIMPA_CARACTER(E.NUMERO), 1, 8) END
        --(SELECT NUMERO
        FROM   T_TELEFONE
        WHERE  IDTELEFONE = (SELECT Max(IDTELEFONE)
                             FROM   T_TELEFONE_PESSOA
                             WHERE  IDPESSOA = PF.IDPESSOAFISICA))              AS TGCN_TEL,
       --(SELECT F_TIRA_CARACTER(AREA)
       (SELECT CASE WHEN F_LIMPA_CARACTER(AREA) IS NULL THEN '0' ELSE F_LIMPA_CARACTER(AREA) END
       FROM   T_TELEFONE
        WHERE  IDTELEFONE = (SELECT Max(IDTELEFONE)
                             FROM   T_TELEFONE_PESSOA
                             WHERE  IDPESSOA = PF.IDPESSOAFISICA))                AS TGCN_DDD,
       (SELECT Max(IDMASCARACARTAOPRESENTE)
        FROM   T_MULTICASHPRESENTE
        WHERE  IDCARTAOLOJA = CL.IDCARTAOLOJA)                                    AS TGCN_COD_MSC,
       (SELECT PLU
        FROM   T_MULTICASHPRESENTE     MP,
               T_MASCARACARTAOPRESENTE MC
        WHERE  MP.IDCARTAOLOJA = CL.IDCARTAOLOJA
        AND    MC.IDMASCARACARTAOPRESENTE = MP.IDMASCARACARTAOPRESENTE)           AS TGCN_COD_PLU,
       LIMITEAPLICADO/100                                                         AS TGCN_LMT_POS,
       Nvl((SELECT Sum(VALORPAGO)
            FROM   T_PAGAMENTO
            WHERE  --IDFATURA = F.IDFATURA
            IDFATURA = (SELECT IDFATURA FROM T_FATURA WHERE IDCLIENTETITULARPESSOAFISICA = CTPF.IDCLIENTETITULARPESSOAFISICA AND ATIVA = 'S')
            AND    STATUS   = 'N'
            AND    MEIOTRANSACAO NOT IN ('S','E','C')),0)
       +
       Nvl((SELECT Sum(VALOR)*(-1)
            FROM   T_LANCAMENTOAJUSTE
            WHERE  IDCLIENTETITULARPESSOAFISICA = CTPF.IDCLIENTETITULARPESSOAFISICA
            AND    FATURADO   = 'N'
            AND    IDTIPOLANCAMENTOAJUSTE = 7),0)                                 AS TGCN_LMT_PRE,
       0                                                                          AS TGCN_LMT_RSC,
       1                                                                          AS TGCN_GRP_COD,
       'zzzz'                                                                     AS TGCN_SNH,
       NULL                                                                       AS TGCN_DAT_PRC,
       NULL                                                                       AS TGCN_TIP_OCR,
       NULL                                                                       AS TGCN_MTV_ERRO,
       REDUCAOLIMITEMP                                                            AS TGCN_REDUCAO_LIMITE,
       IDITF_CARTAO_NEUS
FROM   T_ITF_CARTAO_NEUS                       ITF
       INNER JOIN T_CARTAOLOJA                 CL   ON (CL.IDCARTAOLOJA                     = ITF.IDCARTAOLOJA)
       INNER JOIN T_CLIENTEDEPENDENTEPF        CDPF ON (CDPF.IDCLIENTEDEPENDENTEPF          = ITF.IDCLIENTEDEPENDENTEPF)
       INNER JOIN T_CLIENTETITULARPESSOAFISICA CTPF ON (CTPF.IDCLIENTETITULARPESSOAFISICA   = CDPF.IDCLIENTETITULARPESSOAFISICA)
       INNER JOIN T_LIMITECREDITO              LC   ON (LC.IDCLIENTETITULARPESSOAFISICA     = CTPF.IDCLIENTETITULARPESSOAFISICA)
       INNER JOIN T_ENDERECO                   E    ON (E.IDENDERECO                        = CTPF.IDENDERECORESIDENCIAL)
       INNER JOIN T_PESSOAFISICA               PF   ON (PF.IDPESSOAFISICA                   = CTPF.IDCLIENTETITULARPESSOAFISICA)
       INNER JOIN T_CLIENTEPESSOAFISICA        CPF  ON (CPF.IDCLIENTEPESSOAFISICA           = CTPF.IDCLIENTETITULARPESSOAFISICA)
       INNER JOIN T_CARTAOLOJA                 CT   ON (CT.IDCARTAOLOJA                     = CPF.IDCARTAOLOJA)
       LEFT JOIN T_BANCO                       B    ON (B.IDBANCO                           = CTPF.IDBANCO)
WHERE  ITF.ENVIADO = 'N' AND ITF.OPERACAO <> 'L'
--AND    TRUNC(LC.DATA) >= TRUNC(SYSDATE-180)
AND    Nvl(ITF.idclientedependentepf,-1) > -1
AND    iditf_cartao_neus >= 179398972
AND    lc.idlimiteadicional is null
ORDER BY IDITF_CARTAO_NEUS)
WHERE ROWNUM < 100
AND TGCN_COD_CTO_FUN <> '543299******4007'
ORDER BY IDITF_CARTAO_NEUS;


V_EXECUCAOITF NUMBER := 0;

BEGIN
  V_EXECUCAOITF := S_EXECUCAOITF.NEXTVAL;

  INSERT INTO T_EXECUCAOITF (IDEXECUCAOITF,NOMEJOB,DATAINICIO) VALUES (V_EXECUCAOITF, 'PR_ENVIA_ITF_CARTAO', SYSDATE);

  FOR A IN ITFTRANSACAO LOOP

   --  Dbms_Output.ENABLE(100000);
    Dbms_Output.Put_Line(A.TGCN_COD_CTO_FUN ||' - '|| a.TGCN_NRO_EDR);
    BEGIN
      IF (Length(A.TGCN_MATRICULA) > 12) THEN
         A.TGCN_MATRICULA := SubStr(A.TGCN_MATRICULA, -12);
      END IF;

          INSERT INTO HCHEQUE.TMP_GERA_CTO_NEUS@UNIKHC (TGCN_CLNT_COD_CLI,TGCN_COD_CTO_FUN,TGCN_COD_CTA_FUN,TGCN_SITUACAO,TGCN_TIP_CTO,
                                                TGCN_TIP_ACAO,TGCN_DTA_CDS,TGCN_COD_CTO_DEP,TGCN_FLFN_COD_FIL_CLI,TGCN_NOME,
                                                TGCN_CPF,TGCN_MATRICULA,TGCN_COD_BNC,TGCN_COD_AGC,TGCN_CONTACORRE,TGCN_CCUSTO,
                                                TGCN_DES_CCUSTO,TGCN_DAT_NAS,TGCN_CARGO_FUN,TGCN_DAT_ADS,TGCN_EDR,TGCN_NRO_EDR,
                                                TGCN_BRR,TGCN_CEP,TGCN_CID,TGCN_UF,TGCN_EML,TGCN_TEL,TGCN_DDD,TGCN_COD_MSC,
                                                TGCN_COD_PLU,TGCN_LMT_POS,TGCN_LMT_PRE,TGCN_LMT_RSC,TGCN_SNH,TGCN_DAT_PRC,TGCN_TIP_OCR,
                                                TGCN_MTV_ERRO,TGCN_MTV_BLQ_CAN,TGCN_GRP_COD,TGCN_REDUCAO_LIMITE)
                                        VALUES(A.TGCN_CLNT_COD_CLI,A.TGCN_COD_CTO_FUN,A.TGCN_COD_CTA_FUN,A.TGCN_SITUACAO,A.TGCN_TIP_CTO,
                                                A.TGCN_TIP_ACAO,A.TGCN_DTA_CDS,A.TGCN_COD_CTO_DEP,A.TGCN_FLFN_COD_FIL_CLI,Nvl(A.TGCN_NOME,'SEM NOME'),
                                                A.TGCN_CPF,A.TGCN_MATRICULA,A.TGCN_COD_BNC,A.TGCN_COD_AGC,A.TGCN_CONTACORRE,A.TGCN_CCUSTO,
                                                A.TGCN_DES_CCUSTO,A.TGCN_DAT_NAS,A.TGCN_CARGO_FUN,A.TGCN_DAT_ADS,A.TGCN_EDR,A.TGCN_NRO_EDR,
                                                A.TGCN_BRR,A.TGCN_CEP,A.TGCN_CID,A.TGCN_UF,A.TGCN_EML,A.TGCN_TEL,A.TGCN_DDD,A.TGCN_COD_MSC,
                                                A.TGCN_COD_PLU,A.TGCN_LMT_POS,A.TGCN_LMT_PRE,A.TGCN_LMT_RSC,'xxxxxx',A.TGCN_DAT_PRC,A.TGCN_TIP_OCR,
                                                A.TGCN_MTV_ERRO,A.TGCN_MTV_BLQ_CAN,A.TGCN_GRP_COD,A.TGCN_REDUCAO_LIMITE);

    UPDATE T_ITF_CARTAO_NEUS
    SET    ENVIADO = 'S',
           DATA_ENVIO = SYSDATE
    WHERE  IDITF_CARTAO_NEUS = A.IDITF_CARTAO_NEUS;

    v_qtdetrs := v_qtdetrs + 1;

    IF (v_qtdetrs > 100) THEN

      COMMIT;
      v_qtdetrs := 0;

    END IF;

    EXCEPTION
      WHEN Others THEN
        ROLLBACK;
        Dbms_Output.Put_Line(SQLERRM);
    END;
  END LOOP;
  COMMIT;

  UPDATE T_EXECUCAOITF SET DATAFIM = SYSDATE WHERE IDEXECUCAOITF = V_EXECUCAOITF AND NOMEJOB = 'PR_ENVIA_ITF_CARTAO';
  COMMIT;

END;