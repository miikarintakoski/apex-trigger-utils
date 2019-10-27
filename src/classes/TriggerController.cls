/**
 * Generic class that simplifies the implementation of trigger controllers
 * @author	Miika Rintakoski
 */
public virtual class TriggerController {
    
    /**
     * Run triggers the correct method to be run based on the trigger operation type
     */
    public void run() {
        switch on Trigger.operationType {
            when BEFORE_INSERT { beforeInsert(); }
            when BEFORE_UPDATE { beforeUpdate(); }
            when BEFORE_DELETE { beforeDelete(); }
            when AFTER_INSERT { afterInsert(); }
            when AFTER_UPDATE { afterUpdate(); }
            when AFTER_DELETE { afterDelete(); }
            when AFTER_UNDELETE { afterUndelete(); }
        }
    }
    
    /**
     * Protected method for logic that is run in before insert trigger
     */
    protected virtual void beforeInsert() {}
    
    /**
     * Protected method for logic that is run in before update trigger
     */
    protected virtual void beforeUpdate() {}
    
    /**
     * Protected method for logic that is run in before delete trigger
     */
    protected virtual void beforeDelete() {}
    
    /**
     * Protected method for logic that is run in after insert trigger
     */
    protected virtual void afterInsert() {}
    
    /**
     * Protected method for logic that is run in after update trigger
     */
    protected virtual void afterUpdate() {}
    
    /**
     * Protected method for logic that is run in after delete trigger
     */
    protected virtual void afterDelete() {}
    
    /**
     * Protected method for logic that is run in after undelete trigger
     */
    protected virtual void afterUndelete() {}

}