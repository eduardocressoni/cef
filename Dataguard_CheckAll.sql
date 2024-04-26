###############################################################
# Script para validar configuracoes do dataguard no geral
# Criado por Eduardo Cressoni
# Data da Criacao: 26/04/2024
#
#
###############################################################
set lines 200 pages 500
col type format a20
col units format a15
col comments format a40
COL MESSAGE FORMAT A100
col DEST_NAME for a20
col DESTINATION for a15
col error for a50
alter session set nls_date_format='dd/mon/yyyy hh24:mi:ss';
break on DEST_NAME

select DEST_NAME, INST_ID, DEST_ID, STATUS, TARGET, DESTINATION, ERROR from gv$archive_dest where DEST_ID in (2,3,4) order by 1, 2;

select a.thread#, a.last_sequence, a.last_time, b.last_sequence_applied, b.last_time_applied, a.last_sequence-b.last_sequence_applied qtde_gaps
from  ( select thread#, max(sequence#) last_sequence, max(completion_time) last_time  from v$archived_log  group by thread# ) a  inner join  ( select thread#, max(sequence#) last_sequence_applied, max(completion_time) last_time_applied from v$archived_log  where applied = 'YES'
group by thread# ) b on a.thread# = b.thread#;

break on report
compute sum of ARCHS on report
compute sum of QTDE_GAPS on report
-- STANDBY
select FACILITY, SEVERITY, to_char(TIMESTAMP,'dd-mon-yy hh24:mi:ss') Hora,  MESSAGE from gv$dataguard_status
where SEVERITY = 'Informational' and FACILITY = 'Log Apply Services' order by 3;

select process, status,THREAD#,GROUP#, SEQUENCE#, BLOCK# from v$managed_standby ;

select THREAD#, count(1) ARCHS from v$archived_log where applied='NO' group by THREAD#;

select * from v$recovery_progress;

select a.thread#, a.last_sequence, a.last_time, b.last_sequence_applied, b.last_time_applied, a.last_sequence-b.last_sequence_applied qtde_gaps
from  ( select thread#, max(sequence#) last_sequence, max(completion_time) last_time  from v$archived_log  group by thread# ) a  inner join  ( select thread#, max(sequence#) last_sequence_applied, max(completion_time) last_time_applied from v$archived_log  where applied = 'YES'
group by thread# ) b on a.thread# = b.thread#;
