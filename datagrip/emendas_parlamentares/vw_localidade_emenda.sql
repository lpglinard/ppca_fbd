create definer = root@localhost view emendas_parlamentares.vw_localidade_emenda as
select `eo`.`id_emenda`                       AS `id_emenda`,
       (case
            when (`eo`.`id_cidade` is not null) then concat(`c`.`nome_cidade`, ' - ',
                                                            coalesce(`est`.`sigla_uf`, 'UF Desconhecida'))
            when (`eo`.`id_estado` is not null) then `est`.`nome_estado`
            when (`eo`.`id_regiao` is not null) then `r`.`nome_regiao`
            when (`eo`.`id_abrangencia` is not null) then `ae`.`nome_abrangencia`
            else 'Localidade indefinida' end) AS `localidade`,
       `eo`.`ano_da_emenda`                   AS `ano_da_emenda`,
       `f`.`nome_funcao`                      AS `nome_funcao`,
       `s`.`nome_subfuncao`                   AS `nome_subfuncao`,
       coalesce(`eo`.`valor_empenhado`, 0.00) AS `valor_empenhado`,
       coalesce(`eo`.`valor_pago`, 0.00)      AS `valor_pago`
from ((((((`emendas_parlamentares`.`emendas_otimizada` `eo` left join `emendas_parlamentares`.`cidade` `c`
           on ((`eo`.`id_cidade` = `c`.`id_cidade`))) left join `emendas_parlamentares`.`estado` `est`
          on ((`c`.`id_estado` = `est`.`id_estado`))) left join `emendas_parlamentares`.`regiao` `r`
         on ((`eo`.`id_regiao` = `r`.`id_regiao`))) left join `emendas_parlamentares`.`abrangencia_especial` `ae`
        on ((`eo`.`id_abrangencia` = `ae`.`id_abrangencia`))) left join `emendas_parlamentares`.`funcao` `f`
       on ((`eo`.`id_funcao` = `f`.`codigo_funcao`))) left join `emendas_parlamentares`.`subfuncao` `s`
      on ((`eo`.`id_subfuncao` = `s`.`codigo_subfuncao`)));

