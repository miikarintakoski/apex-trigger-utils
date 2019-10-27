/**
 * Cache for SOQL queries that use Id as a filter
 * @author	Miika Rintakoski
 */
public class QueryCache {
	
    //The query which is used to retrieve missing records from database to cache
    private String query;
    
    //The cached records
    private Map<Id, SObject> recordCache;
    
    /**
     * Initializes new cache for given query
     * @param	query	The query string that is used to get the records to the cache. NOTE: use :recordIds in the query in order for the filter to behave correctly.
     */
    public QueryCache(String query) {
        this.query = query;
        this.recordCache = new Map<Id, SObject>();
    }
    
    /**
     * Retrieves the records by their Ids
     * @param	recordIds	The identifiers of the requested records
     * @return	The records that matched the requested identifiers
     */
    public List<SObject> get(Set<Id> recordIds) {
        if(!recordCache.keySet().containsAll(recordIds)){
            Set<Id> missingIds = new Set<Id>(recordIds);
            missingIds.removeAll(recordCache.keySet());
            recordCache.putAll(this.query(missingIds));
        }
        List<SObject> results = new List<SObject>();
        for(Id recordId : recordIds){
            results.add(recordCache.get(recordId));
        }
        return results;
    }
    
    /**
     * Updates a record in the cache. Can be used when there is a risk that the cached record would be outdated and the caller is able to provide the updated record with all the required fields.
     * @param	record	The record that is updated to the cache
     */
    public void put(SObject record) {
        recordCache.put(record.Id, record);
    }
    
    /**
     * Removes a record from the cache which will enforce requerying the record from database on next get() call. Can be used when there is a risk that the cached record would be outdated.
     * @param	recordId	The identifier of the record to be removed from cache
     */
    public void invalidate(Id recordId) {
        recordCache.remove(recordId);
    }
    
    /**
     * Queries the requested records from the database
     * @param	recordIds	The identifiers of the records to be queried
     * @return	The records that matched the requested identifiers
     */
    private List<SObject> query(Set<Id> recordIds) {
        return Database.query(this.query);
    }
    
}