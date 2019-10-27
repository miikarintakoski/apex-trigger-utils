/**
 * Test methods for QueryCache class
 * @author	Miika Rintakoski
 */
@isTest
private class QueryCacheTests {
    
    //Query for testing cache
    private static final String TEST_QUERY = 'SELECT Id, Name FROM Account WHERE Id IN :recordIds';
    
    //Test data parameters 
    private static final Integer TEST_RECORD_COUNT = 10;
    private static final String TEST_NAME_PREFIX = 'Test Account ';
    private static final String TEST_UPDATED_NAME = 'Updated Name';
    
    /**
     * Initializes test records for the cache
     */
    @testSetup
	static void setupTestData() {
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < TEST_RECORD_COUNT; i++) {
            testAccounts.add(new Account(Name = TEST_NAME_PREFIX + i));
        }
        insert testAccounts;
    }
    
    /**
     * Tests the resulting query usage in caching
     */
    @isTest
    static void cacheGet() {
        Set<Id> testRecordIds = getTestRecordIds();
        QueryCache recordCache = new QueryCache(TEST_QUERY);
        
        Integer queryCountBeforeCaching = Limits.getQueries();
        List<SObject> records = recordCache.get(testRecordIds);
        System.assertEquals(TEST_RECORD_COUNT, records.size(), 'Cache did not return correct records');
        
        Integer queryCountAfterCaching = Limits.getQueries();
        System.assertEquals(queryCountBeforeCaching + 1, queryCountAfterCaching, 'Cache fill did not take exacly one query');
        
        recordCache.get(testRecordIds);
        Integer queryCountAfterCacheHit = Limits.getQueries();
        System.assertEquals(queryCountAfterCaching, queryCountAfterCacheHit, 'Cache hit increased query count incorrectly.');
        
    }
    
    /**
     * Tests the caching when record is invalidated in the cache
     */
    @isTest
    static void cacheInvalidate() {
        Set<Id> testRecordIds = getTestRecordIds();
        QueryCache recordCache = new QueryCache(TEST_QUERY);
        List<SObject> records = recordCache.get(testRecordIds);
        
        Integer queryRowCountBeforeInvalidation = Limits.getQueryRows();
        recordCache.invalidate(records.get(0).Id);
        
        //Check that one missing record will increase query row usage by one
        records = recordCache.get(testRecordIds);
        Integer queryRowCountAfterInvalidation = Limits.getQueryRows();
        System.assertEquals(queryRowCountBeforeInvalidation + 1, queryRowCountAfterInvalidation, 'Cache invalidation increased query row count incorrectly');
    }
    
    /**
     * Tests the caching when record is updated by the cache user
     */
    @isTest
    static void cachePut() {
        Set<Id> testRecordIds = getTestRecordIds();
        QueryCache recordCache = new QueryCache(TEST_QUERY);
        List<Account> records = recordCache.get(testRecordIds);
        
        //Update one Account to the cache
        Account toBeUpdated = new Account();
        toBeUpdated.Id = records.get(0).Id;
        toBeUpdated.Name = TEST_UPDATED_NAME;
        recordCache.put(toBeUpdated);
        
        //Check that cache value was updated correctly
        Map<Id, Account> recordMap = new Map<Id, Account>((List<Account>)recordCache.get(testRecordIds));
        Account cachedVersion = recordMap.get(toBeUpdated.Id);
        System.assertEquals(TEST_UPDATED_NAME, cachedVersion.Name, 'Record was not updated properly to cache');
    }
    
    /**
     * Get the test record identifiers which can be used as a cache parameter
     */
    private static Set<Id> getTestRecordIds() {
        return new Map<Id, Account>([SELECT Id FROM Account]).keySet();
    }
    
}