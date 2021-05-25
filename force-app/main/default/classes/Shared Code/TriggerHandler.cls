/**
 * @description An opinionated trigger handler framework.
 * Originally by Kevin O'Hara github.com/kevinohara80/sfdc-trigger-framework
 * @group Shared Code
 * @see AccountTriggerHandler, PlatformEventRecipesTriggerHandler
 */
public virtual class TriggerHandler {
    // static map of handlername, times run() was invoked
    private static Map<String, TriggerInvocationCount> TriggerInvocationCountMap;
    private static Set<String> bypassedHandlers;

    // the current context of the trigger, overridable in tests
    @testVisible
    protected TriggerContext context;

    // the current context of the trigger, overridable in tests
    @testVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        TriggerInvocationCountMap = new Map<String, TriggerInvocationCount>();
        bypassedHandlers = new Set<String>();
    }
    /**
     * @description Internal TriggerHandler custom exception class
     */
    public class TriggerHandlerException extends Exception {
    }

    /**
     * @description Constructs a trigger handler object and ensures the context
     * is set
     */
    public TriggerHandler() {
        this.setTriggerContext();
    }

    /**
     * @description This is main brokering method that is called by the trigger.
     * It's responsible for determining the proper context, and calling the
     * correct method
     * @example
     * AccountTriggerHandler.run();
     */

    public virtual void run() {
        if (!validateRun()) {
            return;
        }

        addToInvocationCount();

        // dispatch to the correct handler method
        switch on context {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }

        removeFromInvocationCount();
    }

    /**
     * @description Allows developers to prevent trigger loops, or allow
     * a limited number of them by setting the maximum number of times
     * this trigger is called.
     * @param max   A valid number (generally 1) of times you'd like
     * to allow the trigger to run.
     * @example
     * In the context of a TriggerHandler class,
     * this.setMaxInvocationCount(5);
     */
    public void setMaxInvocationCount(Integer max) {
        String handlerName = getHandlerName();
        if (
            !TriggerHandler.TriggerInvocationCountMap.containsKey(handlerName)
        ) {
            TriggerHandler.TriggerInvocationCountMap.put(
                handlerName,
                new TriggerInvocationCount(max)
            );
        } else {
            TriggerHandler.TriggerInvocationCountMap.get(handlerName)
                .setMax(max);
        }
    }

    /**
     * @description Allows developers to turn off the max invocation count
     * @example
     * In the context of a TriggerHandler class,
     * this.clearMaxInvocationCount();
     */
    public void clearMaxInvocationCount() {
        this.setMaxInvocationCount(-1);
    }

    /**
     * @description       Allows developers to conditionally bypass (disable)
     * other triggers that *also* implement this triggerHandler
     * @param handlerName Class name (String) of the trigger handler to bypass
     * @example
     * TriggerHandler.bypass('AccountTriggerHandler');
     */
    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }

    /**
     * @description       Removes a given trigger handler class name from
     * the list of bypassed trigger handlers.
     * @param handlerName Handler class name to remove from the bypass list
     * @example
     * TriggerHandler.clearBypass('AccountTriggerHandler');
     */
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    /**
     * @description       Allows developers to check whether a given trigger
     * handler class is currently bypassed.
     * @param handlerName The name of the trigger handler class to check for
     * @return           `Boolean`
     * @example
     * TriggerHandler.isBypassed('AccountTriggerHandler');
     */
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    /**
     * @description removes all classes from the bypass list
     * @example
     * Triggerhandler.clearAllBypasses();
     */
    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }

    /***************************************
     * private instancemethods
     ***************************************/

    /**
     * @description internal method to forcibly set the trigger context
     */
    @testVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    /**
     * @description    Internal method for manually setting the trigger context
     * @param ctx      The current trigger Context
     * @param testMode Is the trigger running in a test context?
     */
    @testVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if (Trigger.isExecuting && !testMode) {
            switch on Trigger.operationType {
                when BEFORE_INSERT {
                    context = TriggerContext.BEFORE_INSERT;
                }
                when BEFORE_UPDATE {
                    context = TriggerContext.BEFORE_UPDATE;
                }
                when BEFORE_DELETE {
                    context = TriggerContext.BEFORE_DELETE;
                }
                when AFTER_INSERT {
                    context = TriggerContext.AFTER_INSERT;
                }
                when AFTER_UPDATE {
                    context = TriggerContext.AFTER_UPDATE;
                }
                when AFTER_DELETE {
                    context = TriggerContext.AFTER_DELETE;
                }
                when AFTER_UNDELETE {
                    context = TriggerContext.AFTER_UNDELETE;
                }
            }
        } else if (ctx != null && testMode) {
            switch on ctx {
                when 'before insert' {
                    context = TriggerContext.BEFORE_INSERT;
                }
                when 'before update' {
                    context = TriggerContext.BEFORE_UPDATE;
                }
                when 'before delete' {
                    context = TriggerContext.BEFORE_DELETE;
                }
                when 'after insert' {
                    context = TriggerContext.AFTER_INSERT;
                }
                when 'after update' {
                    context = TriggerContext.AFTER_UPDATE;
                }
                when 'after delete' {
                    context = TriggerContext.AFTER_DELETE;
                }
                when 'after undelete' {
                    context = TriggerContext.AFTER_UNDELETE;
                }
                when else {
                    throw new TriggerHandler.TriggerHandlerException(
                        'Unexpected trigger context set'
                    );
                }
            }
        }
    }

    /**
     * @description increment the invocation count
     * @exception   Throws invocation count exception if the max invocation count is reached
     */
    @testVisible
    protected void addToInvocationCount() {
        String handlerName = getHandlerName();
        if (TriggerHandler.TriggerInvocationCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.TriggerInvocationCountMap.get(
                    handlerName
                )
                .increment();
            if (exceeded) {
                Integer max = TriggerHandler.TriggerInvocationCountMap.get(
                        handlerName
                    )
                    .max;
                throw new TriggerHandlerException(
                    'Maximum invocation count of ' +
                    String.valueOf(max) +
                    ' reached in ' +
                    handlerName
                );
            }
        }
    }

    protected void removeFromInvocationCount() {
        String handlerName = getHandlerName();
        if (TriggerHandler.TriggerInvocationCountMap.containsKey(handlerName)) {
            TriggerHandler.TriggerInvocationCountMap.get(handlerName)
                .decrement();
        }
    }

    /**
     * @description make sure this trigger should continue to run
     * @return     `Boolean`
     * @exception   TriggerHandlerException thrown when executing outside of a
     * trigger
     */
    @testVisible
    protected Boolean validateRun() {
        if (!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException(
                'Trigger handler called outside of Trigger execution'
            );
        }
        if (TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }

    /**
     * @description Returns the string version of the handler class being
     * invoked
     * @return     `String` Name of the Handler
     */
    @testVisible
    private String getHandlerName() {
        return String.valueOf(this)
            .substring(0, String.valueOf(this).indexOf(':'));
    }

    /***************************************
     * context methods
     ***************************************/

    /**
     * These methods are all intended to be overridden by
     * individual trigger handlers. They exist here only to
     * establish the 'software contract' that they exist.
     */

    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeInsert() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeUpdate() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeDelete() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterInsert() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterUpdate() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterDelete() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterUndelete() {
    }

    /***************************************
     * inner classes
     ***************************************/

    /**
     * @description inner class for managing the invocation count per handler
     */
    @testVisible
    private class TriggerInvocationCount {
        private Integer max;
        private Integer count;

        /**
         * @description invocation counter method with default of 5.
         */
        public TriggerInvocationCount() {
            this.max = 5;
            this.count = 0;
        }

        /**
         * @description Sets invocation count based on the param.
         * @param max   Maximum number of infocation to allow.
         */
        public TriggerInvocationCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        /**
         * @description Increment the internal counter returning the results of
         * this.exceeded().
         * @return     `Boolean` true if count will exceed max count or is less
         * than 0.
         */
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean decrement() {
            this.count--;
            return this.exceeded();
        }

        /**
         * @description Determines if this we're about to exceed the infocation count.
         * @return     `Boolean` true if less than 0 or more than max.
         */
        public Boolean exceeded() {
            if (this.max < 0) {
                return false;
            }
            if (this.count > this.max) {
                return true;
            }
            return false;
        }

        /**
         * @description Returns the max invocation count.
         * @return     `Integer` max invocation count.
         */
        public Integer getMax() {
            return this.max;
        }

        /**
         * @description Returns the current invocation count.
         * @return     `Integer` current invocation count.
         */
        public Integer getCount() {
            return this.count;
        }

        /**
         * @description Sets the max invocation size
         * @param max   The integer to set max to.
         */
        public void setMax(Integer max) {
            this.max = max;
        }
    }

    /**
     * @description possible trigger contexts
     */
    @testVisible
    public enum TriggerContext {
        BEFORE_INSERT,
        BEFORE_UPDATE,
        BEFORE_DELETE,
        AFTER_INSERT,
        AFTER_UPDATE,
        AFTER_DELETE,
        AFTER_UNDELETE
    }
}
