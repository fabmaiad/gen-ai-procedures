CREATE OR REPLACE PROCEDURE NEWUNIK.pr_equaliza_venc_convenio AS

--declare

cursor c_listaconvenios is
SELECT
     l.idloja,
     agnc.clnt_cod_cli            AS clnt_cod_cli,
     agft_dat_cor                 AS datacor,
     itf_num_seq                  AS num_seq,
     itf_status                   AS itf_status,
     itf_num_fec                  AS nrciclofechamento,
     frcl_limiteproc              AS data_padrao,
     ac.dataproximocorte          AS dataproximocorte,
     ac.proximovencimento         AS proximovencimento,
     To_Date(hcheque.f_cal_vct_fat@unikhc(agnc.clnt_cod_cli,agft_dat_cor + 1), 'DD/MM/YYYY') datavencimentoararas
FROM newunik.t_loja l
INNER JOIN newunik.t_acordoconvenio ac on l.idloja = ac.idloja
INNER JOIN itf_agn_cor@unikhc agnc on ac.idloja = agnc.clnt_cod_cli and ac.sequencialfechamento = agnc.itf_num_fec - 1
WHERE l.status = 'A'
AND ac.status = 'A'
AND ac.dataproximocorte >= Trunc(SYSDATE)
AND To_Date(hcheque.f_cal_vct_fat@unikhc(agnc.clnt_cod_cli,agft_dat_cor + 1), 'DD/MM/YYYY') <> Trunc(ac.proximovencimento)
AND NOT EXISTS (SELECT 1 FROM itf_client@unikhc c WHERE c.clnt_cod_cli = l.idloja AND c.itf_tip_ocr_neus IS NULL AND c.itf_dat >= Trunc(sysdate))
ORDER BY 9;

begin

    for r_listaconvenios in c_listaconvenios loop

      insert into itf_client@unikhc (clnt_cod_cli, itf_status, itf_dat, itf_num_seq, itf_tip_ocr_neus, itf_msg_ret_neus)
      values (r_listaconvenios.idloja, 'A', SYSDATE, itf_client_seq.nextval@unikhc, null, null);

    end loop;

    commit;

end;