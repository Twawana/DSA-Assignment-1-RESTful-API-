import ballerina/http;

service /api on new http:Listener(8080) {

    // =================================================================
    // ASSET CRUD  (mark scheme: "Create and manage resources" - 5 marks)
    // Create + Read are done below as a worked example of the pattern.
    // =================================================================

    # Create a new asset. Rejects duplicate assetTags (409).
    # + newAsset - the asset payload from the client
    # + return - the created asset, or a conflict/error response
    resource function post assets(@http:Payload Asset newAsset) returns Asset|http:Conflict {
        if assetStore.hasKey(newAsset.assetTag) {
            return <http:Conflict>{
                body: {message: "Asset with this assetTag already exists", errorCode: "DUPLICATE_ASSET_TAG"}
            };
        }
        assetStore[newAsset.assetTag] = newAsset;
        return newAsset;
    }

    # Retrieve the full list of assets across the ministry (Global View).
    # + return - array of all known assets
    resource function get assets() returns Asset[] {
        return assetStore.toArray();
    }

    # Look up a single asset by its tag.
    # + assetTag - the unique asset identifier
    # + return - the asset, or 404 if it doesn't exist
    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        Asset? found = assetStore[assetTag];
        if found is Asset {
            return found;
        }
        return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
    }

    # TODO (5 marks - part of "create and manage resources"):
    # Update an existing asset. Decide whether this fully replaces the
    # stored record or merges individual fields, validate the assetTag
    # exists first, then overwrite assetStore[assetTag].
    # + assetTag - the unique asset identifier
    # + updatedAsset - the new asset payload
    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    # TODO (5 marks - part of "create and manage resources"):
    # Delete an asset. Validate it exists, then remove it from assetStore.
    # + assetTag - the unique asset identifier
    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    // =================================================================
    // INSTITUTION / SITE FILTERING  (mark scheme: 3 marks)
    // =================================================================

    # TODO (3 marks): Filter assets by institution only.
    # Hint: `assetStore.toArray().filter(a => a.institution == institution)`
    # + institution - institution name to filter by
    resource function get assets/institution/[string institution]() returns Asset[] {
        return [];
    }

    # TODO (3 marks): Filter assets by institution AND site/campus.
    # + institution - institution name to filter by
    # + site - site/campus name to filter by
    resource function get assets/institution/[string institution]/site/[string site]() returns Asset[] {
        return [];
    }

    // =================================================================
    // MAINTENANCE & OVERDUE CHECKS  (mark scheme: 5 marks)
    // =================================================================

    # TODO (5 marks): Return every asset that has at least one schedule
    # whose dueDate is before today. You'll want `import ballerina/time;`
    # at the top of this file and `time:utcNow()` (or civil date compare)
    # to get today's date, then compare against each Schedule.dueDate.
    # + return - assets with at least one overdue schedule
    resource function get assets/overdue() returns Asset[] {
        return [];
    }

    // =================================================================
    // INSTITUTION MANAGEMENT  (mark scheme: 5 marks)
    // =================================================================

    # Retrieve all registered institutions.
    resource function get institutions() returns Institution[] {
        return institutionStore.toArray();
    }

    # TODO (5 marks): Add a new institution. Guard against a duplicate
    # institutionId the same way asset creation does above.
    # + newInstitution - the institution payload
    resource function post institutions(@http:Payload Institution newInstitution) returns Institution|http:Conflict {
        return newInstitution;
    }

    # TODO (5 marks): Remove an institution by id.
    # + institutionId - the unique institution identifier
    resource function delete institutions/[string institutionId]() returns http:Ok|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    // =================================================================
    // COMPONENTS  (part of "manage resources")
    // =================================================================

    # TODO: Append a component to an asset's components array.
    # + assetTag - the unique asset identifier
    # + newComponent - the component to add
    resource function post assets/[string assetTag]/components(@http:Payload Component newComponent) returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    # TODO: Remove a component from an asset by compId.
    # + assetTag - the unique asset identifier
    # + compId - the component identifier to remove
    resource function delete assets/[string assetTag]/components/[string compId]() returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    // =================================================================
    // SCHEDULES  (mark scheme: 3 marks)
    // =================================================================

    # TODO (3 marks): Add a servicing/booking/maintenance schedule to an asset.
    # + assetTag - the unique asset identifier
    # + newSchedule - the schedule to add
    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule newSchedule) returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    # TODO (3 marks): Remove a schedule from an asset by scheduleId.
    # + assetTag - the unique asset identifier
    # + scheduleId - the schedule identifier to remove
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    // =================================================================
    // WORK ORDERS & TASKS
    // =================================================================

    # TODO: Open a new work order on an asset (e.g. reporting a fault).
    # + assetTag - the unique asset identifier
    # + newWorkOrder - the work order to open
    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder newWorkOrder) returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    # TODO: Update a work order's status/description (e.g. OPEN -> CLOSED).
    # + assetTag - the unique asset identifier
    # + orderId - the work order identifier
    # + updatedWorkOrder - the new work order details
    resource function put assets/[string assetTag]/workorders/[string orderId](@http:Payload WorkOrder updatedWorkOrder) returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    # TODO: Close/remove a work order.
    # + assetTag - the unique asset identifier
    # + orderId - the work order identifier
    resource function delete assets/[string assetTag]/workorders/[string orderId]() returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }

    # TODO: Add a sub-task to an existing work order (e.g. "replace screen").
    # + assetTag - the unique asset identifier
    # + orderId - the work order identifier
    # + newTask - the sub-task to add
    resource function post assets/[string assetTag]/workorders/[string orderId]/tasks(@http:Payload Task newTask) returns Asset|http:NotFound {
        return <http:NotFound>{body: {message: "Not implemented yet", errorCode: "NOT_IMPLEMENTED"}};
    }
}
