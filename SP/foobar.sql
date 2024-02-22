--------------------------------------------------------
--  Arquivo criado - Terça-feira-Fevereiro-20-2024   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function FN_FORMAT_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "UNIKVP"."FN_FORMAT_NUMBER" (P_VALOR NUMBER) RETURN VARCHAR2 IS

  --Func?o para Colocar Mascara em Numero
  VALOR        NUMBER(22,2) := P_VALOR;
  AUX          NUMBER       := 0;
  PARTEINTEIRA VARCHAR2(22);
  PARTEDECIMAL VARCHAR2(2);
  SAIDA        VARCHAR2(100);

BEGIN

  SELECT CASE
           WHEN INSTR(TO_CHAR(VALOR),',') = 0 THEN '00'
           ELSE RPAD(SUBSTR(TO_CHAR(VALOR),1+INSTR(TO_CHAR(VALOR),','),LENGTH(TO_CHAR(VALOR))),2,'0')
         END
  INTO   PARTEDECIMAL
  FROM   DUAL;

  SAIDA := ','||PARTEDECIMAL;

  IF (PARTEDECIMAL = '00') THEN
    PARTEINTEIRA := VALOR;
  ELSE
    SELECT NVL(SUBSTR( TO_CHAR(P_VALOR), 1, INSTR(TO_CHAR(P_VALOR),',') -1),0)
    INTO   PARTEINTEIRA
    FROM   DUAL;
  END IF;

  FOR C IN REVERSE 1..LENGTH(PARTEINTEIRA) LOOP

    AUX := AUX + 1;
    IF (AUX < 3 OR C = 1) THEN
      SAIDA := SUBSTR(PARTEINTEIRA,C,1)||SAIDA;
    ELSIF (AUX = 3) THEN
      SAIDA := '.'||SUBSTR(PARTEINTEIRA,C,1)||SAIDA;
      AUX := 0;
    END IF;

  END LOOP;
  RETURN SAIDA;
END;
 

/
--------------------------------------------------------
--  DDL for Function FN_VALIDACPF
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "UNIKVP"."FN_VALIDACPF" (F_CPF IN CHAR) RETURN NUMBER IS

CPF VARCHAR2(11):= LPad(REPLACE(F_CPF,' ','0'),11,'0');
SOMA INTEGER;
I INTEGER;
DV1 INTEGER;
DV2 INTEGER;

BEGIN

 SOMA:=0;
 FOR I IN 1..9
 LOOP
  SOMA:=SOMA+((11-I)*SUBSTR(CPF,I,1));
 END LOOP;
 DV1:=11 - MOD(SOMA,11);
 IF DV1=10 OR DV1=11 THEN DV1:=0; END IF;

 SOMA:=0;
 FOR I IN 1..10
 LOOP
  SOMA:=SOMA+((12-I)*SUBSTR(CPF,I,1));
 END LOOP;
 DV2:=11 - MOD(SOMA,11);
 IF DV2=10 OR DV2=11 THEN DV2:=0; END IF;

 IF DV1 = SUBSTR(CPF,10,1) AND
    DV2 = SUBSTR(CPF,11,1) THEN
    RETURN(0);
 ELSE
    RETURN(-1);
 END IF;
END;

/
--------------------------------------------------------
--  DDL for Function FN_RETORNA_SALDO_CLIENTE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "UNIKVP"."FN_RETORNA_SALDO_CLIENTE" (P_IDCLIENTE NUMBER) RETURN NUMBER IS
  VALORSALDO NUMBER := 0;
BEGIN
  RETURN VALORSALDO;
END;
 

/
--------------------------------------------------------
--  DDL for Function F_CALCULATAXARECEBIDA
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "UNIKVP"."F_CALCULATAXARECEBIDA" 
   ( totalPago IN NUMBER, previstoParcelas IN NUMBER, previstoTaxas IN NUMBER  )
   RETURN number
IS
  retorno NUMBER;
  saldoPagamento NUMBER;
  auxPrevistoParcelas NUMBER;

BEGIN

    IF previstoParcelas < 0 then
      auxPrevistoParcelas := 0;
    ELSE
      auxPrevistoParcelas := previstoParcelas;
    END IF;

    saldoPagamento :=  totalPago -  auxPrevistoParcelas;

    IF saldoPagamento < 0  THEN
      retorno := 0;
    ELSIF saldoPagamento > previstoTaxas THEN
      retorno :=  previstoTaxas;
    ELSE
      retorno := saldoPagamento;
    END IF;

    RETURN retorno;

EXCEPTION
WHEN OTHERS THEN
      raise_application_error(1000, 'Erro na funcao F_CALCULATAXARECEBIDA');
END;
 

/
--------------------------------------------------------
--  DDL for Function FDATA_CORTE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "UNIKVP"."FDATA_CORTE" (wcli in number) RETURN varchar2 IS

aux_data_fat        date;
aux_data_ult_fat    date;
aux_data_corte      date;
aux_data_ult_agc    date;
aux_ind_frd_nac   Varchar2(1);
aux_dia_semana      number(1);
aux_frd             number(1);
AUX_HE_WM           number    := 0;
aux_data         varchar2(8) := to_char(sysdate+30,'ddmmyyyy');
wdia_fat            number(2) := 0;
aux_qtd_mes      number(1) := 0;



CURSOR c_cliente IS
select  CLNT_COD_CLI
       ,CLNT_FRM_REN_SDO
       ,decode(nvl(FRCL_LIMITEPROC,1),0,1,FRCL_LIMITEPROC) FRCL_LIMITEPROC
       ,CLNT_SITUACAO
  from HCHEQUE.client@UNIKHC, HCHEQUE.ftrcli@UNIKHC
 where CLNT_COD_CLI  = FRCL_CLNT_COD_CLI
   and CLNT_COD_CLI  = wcli;

-- ************************************************************ --
-- *****************   Verifica Feriado *********************** --
-- ************************************************************ --
procedure Verifica_frd  is
begin
  begin
   select FRD_IND_FRD_NAC into aux_ind_frd_nac from hcheque.frd@UNIKHC where FRD_DAT = trunc(aux_data_fat);
  exception
   when no_data_found then
      aux_ind_frd_nac := null;
   when others then
     RAISE_APPLICATION_ERROR(-20560,Rpad(SQLERRM,80));
  end;
end;
-- ************************************************************ --
-- *****************   Verifica Feriado *********************** --
-- ************************************************************ --
procedure Verifica_outro_frd  is
begin
   select count(*) into aux_frd
     from hcheque.frd_cid@UNIKHC
    where FRDC_FRD_DAT  = aux_data_fat
      and FRDC_CID_COD  = 1;
   if aux_frd  = 0 then
      select count(*) into aux_frd
        from hcheque.frd_uf@UNIKHC
       where FRDU_FRD_DAT   = aux_data_fat
         and FRDU_UF_SGL    = 'SP';
   end if;
 end;
-- ************************************************************ --
-- ********************   Verifica Data *********************** --
-- ************************************************************ --
procedure Verifica_data  is
begin
  select to_char(aux_data_fat,'d')into aux_dia_semana from dual;
  if aux_dia_semana = 1 then    -- se Domingo
    aux_data_fat := aux_data_fat - 2 ;  --  Fatura na Sexta
  elsif aux_dia_semana = 7 then    -- se Sabado
    aux_data_fat := aux_data_fat - 1;   --  Fatura na Sexta
  end if;
  Verifica_frd;   -- Verifica se Feriado
  while aux_ind_frd_nac = 'S'  loop
      aux_data_fat := aux_data_fat - 1;    -- Fatura Antes
      select to_char(aux_data_fat,'d')into aux_dia_semana from dual;
      if aux_dia_semana = 1 then       -- se Domingo
       aux_data_fat := aux_data_fat - 2 ;  --  Fatura na Sexta
      elsif aux_dia_semana = 7 then    -- se Sabado
       aux_data_fat := aux_data_fat - 1;   --  Fatura na Sexta
      end if;
      Verifica_frd;   -- Verifica se Feriado
  end loop;
  while aux_ind_frd_nac = 'N'  loop
      Verifica_outro_frd;   -- Verifica se Feriado Municipal ou Estadual
      if aux_frd  = 0 then
        aux_ind_frd_nac := null;
      else
        aux_data_fat := aux_data_fat - 1;    -- Fatura Antes
        select to_char(aux_data_fat,'d')into aux_dia_semana from dual;
        if aux_dia_semana = 1 then    -- se Domingo
         aux_data_fat := aux_data_fat - 2;   --  Fatura na Sexta
        elsif aux_dia_semana = 7 then    -- se Sabado
         aux_data_fat := aux_data_fat - 1;   --  Fatura na Sexta
        end if;
        Verifica_frd;   -- Verifica se Feriado
        while aux_ind_frd_nac = 'S'  loop
          aux_data_fat := aux_data_fat - 1;    -- Fatura Antes
          select to_char(aux_data_fat,'d')into aux_dia_semana from dual;
          if aux_dia_semana = 1 then    -- se Domingo
            aux_data_fat := aux_data_fat - 2;   --  Fatura na Sexta
          elsif aux_dia_semana = 7 then    -- se Sabado
            aux_data_fat := aux_data_fat - 1;   --  Fatura na Sexta
          end if;
          Verifica_frd;   -- Verifica se Feriado
        end loop;
      end if;
  end loop;
end;
-- ************************************************************ --
-- ****************   Rotina Principal  *********************** --
-- ************************************************************ --
Begin
  for r_cliente in c_cliente loop
    --
    select nvl(max(AGFT_DAT_FAT),sysdate-40)
      into aux_data_ult_fat
      from  hcheque.agn_fto@UNIKHC
     where AGFT_CLNT_COD_CLI = r_cliente.CLNT_COD_CLI
      and AGFT_DAT_ENV_ORB is not null;
    --
     select nvl(max(AGFT_DAT_FAT),To_Date('01012005','ddmmyyyy'))
      into aux_data_ult_agc
      from  hcheque.agn_fto@UNIKHC
     where AGFT_CLNT_COD_CLI = r_cliente.CLNT_COD_CLI;
    --
    select
     --decode(sign(trunc(sysdate+1)-trunc(aux_data_ult_agc)),-1,to_char(aux_data_ult_agc,'dd'),
     --        0,to_char(aux_data_ult_agc,'dd'),r_cliente.FRCL_LIMITEPROC)
      decode(aux_data_ult_agc,'01-JAN-05',r_cliente.FRCL_LIMITEPROC,to_char(aux_data_ult_agc,'dd'))
      into wdia_fat
      from dual;
    --
     select
     decode(sign(to_char(last_day(sysdate+1),'dd')-wdia_fat),-1,
                 to_char(last_day(sysdate+1),'dd'),wdia_fat)
       into wdia_fat
      from dual;
    --
    aux_data_fat := to_date(lpad(wdia_fat,2,0)||
                            to_char(trunc(sysdate+1),'mmyyyy')||'200000','ddmmyyyy hh24miss');
    --
      if aux_data_ult_fat > aux_data_fat  then
         aux_qtd_mes  :=  2;
      else
         aux_qtd_mes  :=  1;
      end if;
    --
    if trunc(aux_data_fat)  <=   trunc(sysdate+1) then
       --
       select decode(sign(to_char(last_day(sysdate+1),'dd')-r_cliente.FRCL_LIMITEPROC),-1,
                          to_char(last_day(sysdate+1),'dd'),r_cliente.FRCL_LIMITEPROC)
       into wdia_fat
       from dual;
       --
       aux_data_fat :=  to_date(lpad(wdia_fat,2,0)||
                        to_char(trunc(sysdate+1),'mmyyyy')||'200000','ddmmyyyy hh24miss');
       --
       aux_data_fat :=  add_months(aux_data_fat,aux_qtd_mes );
    end if;
    --
    aux_data_corte :=  aux_data_fat  - 1;

    aux_data := to_char(aux_data_corte,'ddmmyyyy');

  end loop;
  return(aux_data);
end;

/
--------------------------------------------------------
--  DDL for Function F_CALCULAPRINCIPALRECEBIDO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "UNIKVP"."F_CALCULAPRINCIPALRECEBIDO" 
   ( totalPago IN NUMBER, previstoParcelas IN NUMBER )
   RETURN number
IS
  retorno NUMBER;

BEGIN

    IF previstoParcelas < 0 then
      retorno := 0;
    ELSIF totalPago < previstoParcelas  THEN
      retorno := totalPago;
    ELSE
      retorno :=  previstoParcelas;
    END IF;

    RETURN retorno;

EXCEPTION
WHEN OTHERS THEN
      raise_application_error(1000, 'Erro na funcao F_CALCULAPRINCIPALRECEBIDO');
END;
 

/
--------------------------------------------------------
--  DDL for Function FN_RET_TRANS_FASTCRED
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "UNIKVP"."FN_RET_TRANS_FASTCRED" (P_IDDADOSTRANSACAOFRETE NUMBER) RETURN VARCHAR2
IS
   V_TIPO_TRANS  VARCHAR2(40);

BEGIN

     SELECT CASE WHEN ID_TIPO_TRANSACAO = 0 THEN 'ADIANTAMENTO' ELSE 'QUITACAO' END
       INTO V_TIPO_TRANS
       FROM UNIKVP.T_DADOSTRANSACAOFRETE DTF INNER JOIN FASTCARD.TAB_TRANSACAO FC ON (DTF.NUMEROAUTORIZACAO = FC.CD_AUTORIZACAO )
      WHERE IDDADOSTRANSACAOFRETE = P_IDDADOSTRANSACAOFRETE;
            
      RETURN V_TIPO_TRANS;

END;

/
--------------------------------------------------------
--  DDL for Function FN_TIPO_ULTIMO_BLOQUEIO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "UNIKVP"."FN_TIPO_ULTIMO_BLOQUEIO" (P_CARTAO VARCHAR2) RETURN NUMBER AS

  V_ULTIMOBLOQUEIO     NUMBER;
  R_TIPOULTIMOBLOQUEIO NUMBER;

BEGIN

  SELECT MAX(IDBLOQUEIOCARTAO)
  INTO   V_ULTIMOBLOQUEIO
  FROM   T_BLOQUEIOCARTAO BC,
         T_CARTAOLOJA     CL
  WHERE  CL.NUMEROMANUAL   = P_CARTAO
  AND    BC.IDCARTAOLOJA   = CL.IDCARTAOLOJA
  AND    BC.LIBERADO       = 'N';

  IF (V_ULTIMOBLOQUEIO IS NOT NULL) THEN
    SELECT IDTIPOBLOQUEIOCARTAO
    INTO   R_TIPOULTIMOBLOQUEIO
    FROM   T_BLOQUEIOCARTAO
    WHERE  IDBLOQUEIOCARTAO = V_ULTIMOBLOQUEIO;
  END IF;

  RETURN R_TIPOULTIMOBLOQUEIO;

END;
