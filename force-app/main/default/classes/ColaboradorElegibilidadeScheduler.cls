public with sharing class ColaboradorElegibilidadeScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ColaboradorElegibilidadeBatch());
    }
}
