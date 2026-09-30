// Módulo 7 — registra o Scheduled Job semanal do ColaboradorElegibilidadeBatch.
//
// System.schedule() não é metadado deployável: ele cria um registro CronTrigger em
// runtime na org, então não existe "source" pra isso em force-app. Este script é a
// referência versionada do comando que foi executado (via Execute Anonymous / sf apex run)
// para criar o job "Elegibilidade Semanal Colaboradores" — toda segunda-feira às 08h.
//
// Rodar de novo com o mesmo nome enquanto o job anterior ainda existir vai falhar
// (CronTrigger com esse nome já existe). Pra recriar, cancele o job antigo primeiro
// em Setup > Scheduled Jobs, ou troque o nome abaixo.

String cronExp = '0 0 8 ? * MON';
String jobId = System.schedule(
    'Elegibilidade Semanal Colaboradores',
    cronExp,
    new ColaboradorElegibilidadeScheduler()
);
System.debug('Scheduled Job Id: ' + jobId);
