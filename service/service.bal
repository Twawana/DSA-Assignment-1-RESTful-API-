import ballerina/http;
import ballerina/time;

int scheduleIdCounter = 0;
int componentIdCounter = 0;
int workOrderIdCounter = 0;
int taskIdCounter = 0;

function generateScheduleId(string assetTag) returns string {
    lock {
        scheduleIdCounter += 1;
    }
    return assetTag + "-SCH-" + scheduleIdCounter.toString();
}

function generateComponentId(string assetTag) returns string {
    lock {
        componentIdCounter += 1;
    }
    return assetTag + "-COMP-" + componentIdCounter.toString();
}

function generateWorkOrderId(string assetTag) returns string {
    lock {
        workOrderIdCounter += 1;
    }
    return assetTag + "-WO-" + workOrderIdCounter.toString();
}

function generateTaskId(string assetTag) returns string {
    lock {
        taskIdCounter += 1;
    }
    return assetTag + "-TASK-" + taskIdCounter.toString();
}

function isPastDue(string dueDate) returns boolean {
    time:Utc|error dueUtc = time:utcFromString(dueDate + "T00:00:00.00Z");
    if dueUtc is error {
        return false; 
    }
    time:Utc now = time:utcNow();
    return time:utcDiffSeconds(now, dueUtc) > 0d;
}

service /api on new http:Listener(8080) {


    resource function post assets(@http:Payload Asset newAsset) returns Asset|http:Conflict {
        if assetStore.hasKey(newAsset.assetTag) {
            return <http:Conflict>{
                body: {message: "Asset with this assetTag already exists", errorCode: "DUPLICATE_ASSET_TAG"}
            };
        }
        assetStore[newAsset.assetTag] = newAsset;
        return newAsset;
    }


    resource function get assets() returns Asset[] {
        return assetStore.toArray();
    }


    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        Asset? found = assetStore[assetTag];
        if found is Asset {
            return found;
        }
        return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
    }


    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns Asset|http:NotFound {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        Asset replacement = {
            assetTag: assetTag,
            name: updatedAsset.name,
            description: updatedAsset?.description,
            institution: updatedAsset.institution,
            site: updatedAsset.site,
            status: updatedAsset.status,
            dateAcquired: updatedAsset.dateAcquired,
            components: updatedAsset.components,
            schedules: updatedAsset.schedules,
            workOrders: updatedAsset.workOrders
        };
        assetStore[assetTag] = replacement;
        return replacement;
    }


    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }
        _ = assetStore.remove(assetTag);
        return <http:Ok>{body: {message: "Asset deleted", assetTag: assetTag}};
    }

    // =================================================================
    // INSTITUTION / SITE FILTERING  (mark scheme: 3 marks)
    // =================================================================


    resource function get assets/institution/[string institution]() returns Asset[] {
        return assetStore.toArray().filter(function (Asset asset) returns boolean {
            return asset.institution == institution;
        });
    }


    resource function get assets/institution/[string institution]/site/[string site]() returns Asset[] {
        return assetStore.toArray().filter(function (Asset asset) returns boolean {
            return asset.institution == institution && asset.site == site;
        });
    }

    // =================================================================
    // MAINTENANCE & OVERDUE CHECKS  (mark scheme: 5 marks)
    // =================================================================


    resource function get assets/overdue() returns Asset[] {
        return assetStore.toArray().filter(function (Asset asset) returns boolean {
            foreach Schedule sched in asset.schedules {
                if isPastDue(sched.dueDate) {
                    return true;
                }
            }
            return false;
        });
    }

    // =================================================================
    // INSTITUTION MANAGEMENT  (mark scheme: 5 marks)
    // =================================================================


    resource function get institutions() returns Institution[] {
        return institutionStore.toArray();
    }


    resource function post institutions(@http:Payload Institution newInstitution) returns Institution|http:Conflict {
        if institutionStore.hasKey(newInstitution.institutionId) {
            return <http:Conflict>{
                body: {message: "Institution with this institutionId already exists", errorCode: "DUPLICATE_INSTITUTION_ID"}
            };
        }
        institutionStore[newInstitution.institutionId] = newInstitution;
        return newInstitution;
    }


    resource function delete institutions/[string institutionId]() returns http:Ok|http:NotFound {
        if !institutionStore.hasKey(institutionId) {
            return <http:NotFound>{body: {message: "Institution not found", errorCode: "INSTITUTION_NOT_FOUND"}};
        }
        _ = institutionStore.remove(institutionId);
        return <http:Ok>{body: {message: "Institution deleted", institutionId: institutionId}};
    }

    // =================================================================
    // COMPONENTS  (part of "manage resources")
    // =================================================================


    resource function post assets/[string assetTag]/components(@http:Payload Component newComponent) returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        string compId = newComponent.compId.trim().length() > 0
            ? newComponent.compId
            : generateComponentId(assetTag);

        Component componentToAdd = {
            compId: compId,
            name: newComponent.name,
            description: newComponent?.description
        };

        asset.components.push(componentToAdd);
        assetStore[assetTag] = asset;

        return asset;
    }


    resource function delete assets/[string assetTag]/components/[string compId]() returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        int? indexToRemove = ();
        foreach int i in 0 ..< asset.components.length() {
            if asset.components[i].compId == compId {
                indexToRemove = i;
                break;
            }
        }

        if indexToRemove is () {
            return <http:NotFound>{
                body: {message: "Component not found on this asset", errorCode: "COMPONENT_NOT_FOUND"}
            };
        }

        _ = asset.components.remove(indexToRemove);
        assetStore[assetTag] = asset;

        return asset;
    }

    // =================================================================
    // SCHEDULES  (mark scheme: 3 marks)
    // =================================================================


    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule newSchedule) returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        string scheduleId = newSchedule.scheduleId.trim().length() > 0
            ? newSchedule.scheduleId
            : generateScheduleId(assetTag);

        Schedule scheduleToAdd = {
            scheduleId: scheduleId,
            'type: newSchedule.'type,
            dueDate: newSchedule.dueDate,
            description: newSchedule?.description
        };

        asset.schedules.push(scheduleToAdd);
        assetStore[assetTag] = asset;

        return asset;
    }

    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        int? indexToRemove = ();
        foreach int i in 0 ..< asset.schedules.length() {
            if asset.schedules[i].scheduleId == scheduleId {
                indexToRemove = i;
                break;
            }
        }

        if indexToRemove is () {
            return <http:NotFound>{
                body: {message: "Schedule not found on this asset", errorCode: "SCHEDULE_NOT_FOUND"}
            };
        }

        _ = asset.schedules.remove(indexToRemove);
        assetStore[assetTag] = asset;

        return asset;
    }

    // =================================================================
    // WORK ORDERS & TASKS
    // =================================================================


    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder newWorkOrder) returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        string orderId = newWorkOrder.orderId.trim().length() > 0
            ? newWorkOrder.orderId
            : generateWorkOrderId(assetTag);

        string status = newWorkOrder.status.trim().length() > 0
            ? newWorkOrder.status
            : "OPEN";

        WorkOrder workOrderToAdd = {
            orderId: orderId,
            status: status,
            description: newWorkOrder.description,
            tasks: []
        };

        asset.workOrders.push(workOrderToAdd);
        assetStore[assetTag] = asset;

        return asset;
    }


    resource function put assets/[string assetTag]/workorders/[string orderId](@http:Payload WorkOrder updatedWorkOrder) returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        int? indexToUpdate = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].orderId == orderId {
                indexToUpdate = i;
                break;
            }
        }

        if indexToUpdate is () {
            return <http:NotFound>{
                body: {message: "Work order not found on this asset", errorCode: "WORK_ORDER_NOT_FOUND"}
            };
        }

        WorkOrder existing = asset.workOrders[indexToUpdate];
        string status = updatedWorkOrder.status.trim().length() > 0
            ? updatedWorkOrder.status
            : existing.status;
        string description = updatedWorkOrder.description.trim().length() > 0
            ? updatedWorkOrder.description
            : existing.description;

        asset.workOrders[indexToUpdate] = {
            orderId: existing.orderId,
            status: status,
            description: description,
            tasks: existing.tasks
        };
        assetStore[assetTag] = asset;

        return asset;
    }


    resource function delete assets/[string assetTag]/workorders/[string orderId]() returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        int? indexToRemove = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].orderId == orderId {
                indexToRemove = i;
                break;
            }
        }

        if indexToRemove is () {
            return <http:NotFound>{
                body: {message: "Work order not found on this asset", errorCode: "WORK_ORDER_NOT_FOUND"}
            };
        }

        _ = asset.workOrders.remove(indexToRemove);
        assetStore[assetTag] = asset;

        return asset;
    }


    resource function post assets/[string assetTag]/workorders/[string orderId]/tasks(@http:Payload Task newTask) returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found", errorCode: "ASSET_NOT_FOUND"}};
        }

        int? workOrderIndex = ();
        foreach int i in 0 ..< asset.workOrders.length() {
            if asset.workOrders[i].orderId == orderId {
                workOrderIndex = i;
                break;
            }
        }

        if workOrderIndex is () {
            return <http:NotFound>{
                body: {message: "Work order not found on this asset", errorCode: "WORK_ORDER_NOT_FOUND"}
            };
        }

        string taskId = newTask.taskId.trim().length() > 0
            ? newTask.taskId
            : generateTaskId(assetTag);

        Task taskToAdd = {
            taskId: taskId,
            description: newTask.description,
            completed: newTask.completed
        };

        WorkOrder existing = asset.workOrders[workOrderIndex];
        existing.tasks.push(taskToAdd);
        asset.workOrders[workOrderIndex] = existing;
        assetStore[assetTag] = asset;

        return asset;
    }
}
