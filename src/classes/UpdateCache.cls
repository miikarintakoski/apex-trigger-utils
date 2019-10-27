/**
 * Cache for DML update operations
 * @author	Miika Rintakoski
 */
public class UpdateCache {
	
    //Record cache
    private Map<Id, SObject> cachedRecords;
    
    /**
     * Initializes new UpdateCache
     */
    public UpdateCache() {
        cachedRecords = new Map<Id, SObject>();
    }
    
    /**
     * Caches updated records for later database update
     * @param   records The records to be caches
     */
    public void setRecordsForUpdate(List<SObject> records) {
        for(SObject record : records) {
            if(cachedRecords.containsKey(record.Id)) {
                SObject cachedRecord = cachedRecords.get(record.Id);
                Map<String, Object> updatedFields = record.getPopulatedFieldsAsMap();
                for(String updatedFieldName : updatedFields.keySet()) {
                    cachedRecord.put(updatedFieldName, updatedFields.get(updatedFieldName));
                }
            } else {
                cachedRecords.put(record.Id, record);
            }
        }
    }
    
    /**
     * Persists the changes to database
     * @param   allOrNone   Specifies whether the operation allows partial success
     * @return  The results of the database operation
     */
    public List<Database.SaveResult> updateRecords(Boolean allOrNone) {
        return Database.update(cachedRecords.values(), allOrNone);
    }
    
}