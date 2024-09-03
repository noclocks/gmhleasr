#  ------------------------------------------------------------------------
#
# Title : Entrata Endpoints Data Preparation
#    By : Jimmy Briggs
#  Date : 2024-08-17
#
#  ------------------------------------------------------------------------

# see https://gmhcommunities.entrata.com/api/v1/documentation

# endpoints ---------------------------------------------------------------

entrata_api_request_endpoints <- c(
  "status",
  "applications",
  "arcodes",
  "arpayments",
  "artransactions",
  "communications",
  "customers",
  "financial",
  "leads",
  "leases",
  "leasingcenter",
  "maintenance",
  "pricing",
  "properties",
  "pricing",
  "propertyunits",
  "queue",
  "reports",
  "vendors"
)


# entrata api endpoint methods --------------------------------------------

entrata_api_request_methods <- list(
  "status" = c(
    "getStatus"
  ),
  "applications" = c(
    "getCompanyApplications",
    "sendApplicantGeneralDetails",
    "sendApplication",
    "sendApplicationAddOns",
    "sendApplicationEmployers",
    "sendApplicationPets",
    "sendApplicationVehicles",
    "updateApplication"
  ),
  "arcodes" = c(
    "getArCodes"
  ),
  "arpayments" = c(
    "getArPayments"
  ),
  "artransactions" = c(
    "getArInvoices",
    "getLeaseArTransactions",
    "getMitsLeaseArTransactions",
    "sendLeaseArTransactionReversals",
    "sendLeaseArTransactions"
  ),
  "communications" = c(
    "getMarketingPreferencePickList",
    "getMarketingPreferences"
  ),
  "customers" = c(
    "getCustomers",
    "getCustomerTestimonials",
    "getTestimonialPickLists",
    "searchCustomers",
    "sendCustomerTestimonials",
    "updateCustomers",
    "updateCustomerTestimonials",
    "updatePropertyResponse"
  ),
  "financial" = c(
    "getApCodes",
    "getBankAccounts",
    "getBudgetActuals",
    "getBudgets",
    "getFinancialPickList",
    "getGlTransactions",
    "getGlTrees",
    "getJobCategories",
    "getJobCostBudgets",
    "getJobs",
    "getTransactionTagLists",
    "markGlTransactionsExported",
    "sendBudgets",
    "sendJournalEntries",
    "updateBudgets"
  ),
  "leads" = c(
    "applyQuote",
    "generateQuotes",
    "getLeadEvents",
    "getLeadPickLists",
    "getLeads",
    "getMitsLeads",
    "getQuotes",
    "sendLeads",
    "sendMitsLeads",
    "updateLeads"
  ),
  "leases" = c(
    "cancelLease",
    "getEvictedLeases",
    "getExpiringLeases",
    "getLeaseDetails",
    "getLeaseDocuments",
    "getLeaseDocumentsList",
    "getLeasePickList",
    "getLeases",
    "getMitsCollections",
    "getMitsLeases",
    "getParcelAlerts",
    "getRentersInsurancePolicies",
    "moveInLease",
    "moveOutLease",
    "onNoticeLease",
    "sendLeaseActivities",
    "sendLeaseDocuments",
    "sendLeases",
    "sendRentersInsurancePolicies",
    "sendRoommateGroups",
    "sendScheduledCharges",
    "updateLease",
    "updateScheduledCharges"
  ),
  "leasingcenter" = c(
    "getCallLogs",
    "getLeasingCenterPickLists"
  ),
  "maintenance" = c(
    "getInspections",
    "getInspectionTemplates",
    "getWorkOrderPickLists",
    "getWorkOrders",
    "sendWorkOrders",
    "updateWorkOrders"
  ),
  "pricing" = c(
    "getPricingPicklists",
    "insertPricing",
    "sendBudgetedRent"
  ),
  "properties" = c(
    "getAmenityReservations",
    "getCalendarAvailability",
    "getFloorPlans",
    "getPetTypes",
    "getPhoneNumber",
    "getProperties",
    "getPropertyAddOns",
    "getPropertyAnnouncements",
    "getPropertyPickLists",
    "getRentableItems",
    "getReservableAmenities",
    "getWebsites",
    "sendFloorplans",
    "sendRentableItems"
  ),
  "propertyunits" = c(
    "getAmenities",
    "getMitsPropertyUnits",
    "getPropertyUnits",
    "getSpecials",
    "getUnitsAvailabilityAndPricing",
    "getUnitTypes",
    "sendAmenities",
    "sendPropertyUnits",
    "updateAmenities"
  ),
  "queue" = c("getResponse"),
  "reports" = c(
    "getDependentFilter",
    "getReportData",
    "getReportInfo",
    "getReportList"
  ),
  "vendors" = c(
    "getInvoices",
    "getPoReceivingRecords",
    "getPurchaseOrders",
    "getTaxFormData",
    "getVendorLocations",
    "getVendorPickLists",
    "getVendors",
    "markInvoicesExported",
    "sendInvoices",
    "sendPurchaseOrders",
    "sendVendors",
    "updateInvoices",
    "updateVendors",
    "voidApPayments"
  )
)


# define the "important" entrata api endpoint methods ---------------------

important_entrata_request_endpoint_methods <- list(
  "status" = c(
    "getStatus"
  ),
  "customers" = c(
    "getCustomers"
  ),
  "financial" = c(
    "getBudgetActuals",
    "getBudgets"
  ),
  "leases" = c(
    "getLeases",
    "getLeaseDetails",
    "getLeaseDocuments",
    "getLeaseDocumentsList"
  ),
  "properties" = c(
    "getProperties",
    "getFloorPlans",
    "getPropertyAddOns",
    "getPropertyAnnouncements",
    "getPropertyRentableItems"
  ),
  "propertyunits" = c(
    "getPropertyUnits",
    "getUnitTypes"
  ),
  "queue" = c(
    "getResponse"
  ),
  "reports" = c(
    "getReportData",
    "getReportInfo",
    "getReportList"
  )
)

# merge -------------------------------------------------------------------

# Merge and process endpoint and method data
entrata_api_request_endpoint_methods <- tibble::enframe(
  entrata_api_request_methods,
  name = "endpoint",
  value = "method"
) |>
  tidyr::unnest(cols = c(method)) |>
  dplyr::left_join(
    y = tibble::enframe(
      important_entrata_request_endpoint_methods,
      name = "endpoint",
      value = "method"
    ) |>
      tidyr::unnest(cols = c(method)) |>
      dplyr::mutate(
        important = TRUE
      ),
    by = c("endpoint", "method")
  ) |>
  dplyr::mutate(
    important = dplyr::coalesce(important, FALSE)
  ) |>
  dplyr::arrange(dplyr::desc(important))

# parameters --------------------------------------------------------------

entrata_api_request_parameters <- list(
  "status" = list(
    "getStatus" = list(NA_character_)
    ),
  "customers" = list(
    "getCustomers" = list(
      propertyId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value for the Property ID."),
      "customerIds" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma separated multiple values for the Customer IDs."
      ),
      "leaseStatusTypeIds" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma separated multiple values for the Lease Status Type IDs."
      ),
      "isAgreedToTermsOnly" = list(
        type = "boolean_string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value. isAgreedToTermsOnly returns the date when a customer has agreed to the Terms and Conditions of Entrata resident portal."
      ),
      "companyIdentificationTypeIds" = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma seperated multiple values. company Identification type IDs."
      )
    )
  ),
  "financial" = list(
    "getBudgetActuals" = list(
      propertyId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value. propertyId"),
      glTreeId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value."),
      budgetId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value."),
      postMonthFrom = list(type = "string", required = TRUE, description = "This is a required field. This field accepts single value. MM/YYYY"),
      postMonthTo = list(type = "string", required = TRUE, description = "This is a required field. This field accepts single value. MM/YYYY"),
      glBookTypeIds = list(type = "integer", required = FALSE, multiple = TRUE, description = "This is an optional field. This field accepts comma separated multiple values. glBookTypeIds"),
      budgetStatusTypeId = list(type = "integer", required = FALSE, description = "This is an optional field. This field accepts single value. budgetStatusTypeId"),
      accountingMethod = list(type = "string", required = TRUE, description = "This is a required field. This field accepts single value. accountingMethod")
    ),
    "getBudgets" = list(
      propertyId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value. propertyId"),
      "budgetIds" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma separated multiple values for the Budget IDs."
      ),
      "budgetStatusTypeIds" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma separated multiple values for the Budget Status Type IDs."
      ),
      "fiscalYears" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma separated multiple values for the Fiscal Years."
      )
    )
  ),
  "leases" = list(
    "getLeases" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = "This is a required field. This field accepts single value."
      ),
      applicationId = list(
        type = "integer",
        required = FALSE,
        description = "This is an optional field. This field accepts single value."
      ),
      customerId = list(type = "integer", required = FALSE, description = "This is an optional field. This field accepts single value."),
      leaseStatusTypeIds = list(type = "integer", required = FALSE, multiple = TRUE, description = "This is an optional field. This field accepts comma separated multiple values."),
      leaseIds = list(type = "integer", required = FALSE, multiple = TRUE, description = "This is an optional field. This field accepts comma separated multiple values."),
      scheduledArCodeIds = list(type = "integer", required = FALSE, multiple = TRUE, description = "This is an optional field. This field accepts comma separated multiple values."),
      unitNumber = list(type = "string", required = FALSE, description = "This is an optional field. This field accepts single value."),
      buildingName = list(type = "string", required = FALSE, description = "This is an optional field. This field accepts single value."),
      moveInDateFrom = list(type = "date", required = FALSE, description = "This is an optional field. This field accepts single value."),
      moveInDateTo = list(type = "date", required = FALSE, description = "This is an optional field. This field accepts single value."),
      leaseExpiringDateFrom = list(type = "date", required = FALSE, description = "This is an optional field. This field accepts single value."),
      leaseExpiringDateTo = list(type = "date", required = FALSE, description = "This is an optional field. This field accepts single value."),
      moveOutDateFrom = list(type = "date", required = FALSE, description = "This is an optional field. This field accepts single value."),
      moveOutDateTo = list(type = "date", required = FALSE, description = "This is an optional field. This field accepts single value."),
      includeOtherIncomeLeases = list(type = "boolean_string", required = FALSE, description = "This is an optional field. This field accepts single value."),
      residentFriendlyMode = list(type = "boolean_string", required = FALSE, description = "This is an optional field. This field accepts single value."),
      includeLeaseHistory = list(type = "boolean_string", required = FALSE, description = "This is an optional field. This field accepts single value."),
      includeArTransactions = list(type = "boolean_string", required = FALSE, description = "This is an optional field. This field accepts single value. This should return the Ar Transactions associated with the lease.")
    ),
    # Add other methods for the "leases" endpoint here
    "getLeaseDetails" = list(
      propertyId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value."),
      leaseId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value."),
      leaseStatusTypeIds = list(type = "integer", required = FALSE, multiple = TRUE, description = "This is an optional field. This field accepts comma separated multiple values."),
      includeAddOns = list(type = "boolean_string", required = FALSE, description = "This is an optional field. This field accepts single value."),
      includeCharge = list(type = "boolean_string", required = FALSE, description = "This is an optional field. This field accepts single value.")
    ),
    "getLeaseDocuments" = list(
      propertyId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value."),
      leaseId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value."),
      externalLeaseId = list(type = "string", required = FALSE, description = "This is an optional field. This field accepts single value. Its remote primary key which is associated to lease."),
      documentIds = list(type = "integer", required = FALSE, multiple = TRUE, description = "This is an optional field. This field accepts comma separated multiple values."),
      fileTypesCode = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = "	This is an optional field. This field accepts comma seperated multiple values. System code for file files."
      ),
      addedOnFromDate = list(type = "date", required = FALSE, description = "This is an optional field. This field accepts single value. If provided, this will return the documents which have AddedOn dates o n or after the date provided."),
      showDeletedFile = list(type = "boolean_string", required = FALSE, description = "This is an optional field. This field accepts single value. If provided, this will return the documents which have been deleted.")
    ),
    "getLeaseDocumentsList" = list(
      propertyId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value."),
      leaseId = list(type = "integer", required = TRUE, description = "This is a required field. This field accepts single value."),
      externalLeaseId = list(type = "string", required = FALSE, description = "This is an optional field. This field accepts single value. Its remote primary key which is associated to lease."),
      fileTypesCode = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma separated multiple values. System code for file files."
      ),
      showDeletedFile = list(type = "boolean_string", required = FALSE, description = "This is an optional field. This field accepts single value. If provided, this will return the documents which have been deleted."),
      leaseStatusTypeIds = list(type = "integer", required = FALSE, multiple = TRUE, description = "This is an optional field. This field accepts comma separated multiple values.")
    )
  ),
  "properties" = list(
    "getProperties" = list(
      propertyIds = list(
        type = "string_list",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma seperated multiple values (cancatenated into a single, comma-separated string) representing PropertyIds."
      ),
      propertyLookupCode = list(
        type = "string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value for the Property Lookup Code."
      ),
      showAllStatus = list(
        type = "boolean_string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value."
      )
    ),
    "getFloorPlans" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = "This is a required field. This field accepts single value."
      ),
      propertyFloorPlanIds = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma seperated multiple values. propertyFloorPlanIds."
      ),
      usePropertyPreferences = list(
        type = "boolean_string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value. Checks for the property settings manipulate floorplan data and honour those settings."
      ),
      includeDisabledFloorPlans = list(
        type = "boolean_string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value. If provided value is 1, then user should get disabled floorplans along with the enabled one."
      )
    ),
    "getPropertyAddOns" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = "This is a required field. This field accepts single value."
      ),
      addOnIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma separated multiple values for the Add On IDs."
      )
    ),
    "getPropertyAnnouncements" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = "This is a required field. This field accepts single value."
      ),
      announcementIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = "This is an optional field. This field accepts comma separated multiple values for the Announcement IDs."
      )
    ),
    "getPropertyRentableItems" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = "This is a required field. This field accepts single value."
      ),
      rentableItemIds = list(type = "integer", required = FALSE, multiple = TRUE, description = "This is an optional field. This field accepts comma separated multiple values for the Rentable Item IDs.")
    )
  ),
  "propertyunits" = list(
    "getPropertyUnits" = list(
      propertyIds = list(
        type = "string",
        required = TRUE,
        multiple = TRUE,
        description = "This is a required field. This field accepts comma seperated multiple values."
      ),
      availableUnitsOnly = list(
        type = "boolean_string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value. If provided value is 1, then user should get only available units."
      ),
      usePropertyPreferences = list(
        type = "boolean_string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value. If enabled then the Entrata setting 'Max Available Units per Floor Plan' will be honored and the available units returned will be reduced. Also requires using the availableUnitsOnly parameter as true (1)."
      ),
      includeDisabledFloorPlans = list(
        type = "boolean_string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value. If provided value is 1, then user should get disabled floorplans along with the enabled one."
      ),
      includeDisabledUnits = list(
        type = "boolean_string",
        required = FALSE,
        description = "This is an optional field. This field accepts single value. If provided value is 1, then user should get disabled units along with the enabled one."
      )
    ),
    "getUnitTypes" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        multiple = FALSE,
        description = "This is a required field. This field accepts single value."
      )
    )
  ),
  "queue" = list(
    "getResponse" = list(
      queueId = list(
        type = "string",
        required = TRUE,
        description = "This is a required field. This field accepts single value. This node accepts the queueId. This should be a JWT token. This token should get generated from the getReportData(r3) version."
      ),
      serviceName = list(
        type = "string",
        required = TRUE,
        description = "This is a required field. This field accepts single value. This node accepts the service name for which the apiToken is added."
      )
    )
  ),
  "reports" = list(
    "getReportDependentFilter" = list(
      reportName = list(
        type = "string",
        required = TRUE,
        description = "This is a required field. This field accepts single value. Once passing this parameter web service will return values of the depe ndent filter for that report."
      ),
      dependentFilter = list(
        type = "string",
        required = TRUE,
        description = "This is a required field. This field accepts single value. We will be getting values of these filters in response, that are depen dent on the parent fields that would be mentioned in 'filters' section."
      ),
      filters = list(
        type = "string",
        required = TRUE,
        description = "This is a required field. This field accepts single value. Here parent filters are mentioned considering those values of dependen t filters will be getting in the response of this web service."
      )
    ),
    "getReportData" = list(
      reportName = list(
        type = "string",
        required = TRUE,
        description = "This is a required field. This field accepts single value. Once passing this parameter web service will return report data for th at report."
      ),
      reportVersion = list(
        type = "string",
        required = TRUE,
        description = "This is an optional field. This field accepts single value. Will filter result as per the report available report versions."
      ),
      filters = list(
        type = "object",
        required = TRUE,
        description = "This is a required field. This field accepts single value. For each report there are filter parameters that are required, like property id, dates etc. You can get filters for each report using the getReportsInfo webservice."
      )
    ),
    "getReportInfo" = list(
      reportName = list(type = "string", required = TRUE, description = "This is a required field. This field accepts single value. This node accepts the reportName."),
      reportVersion = list(type = "string", required = FALSE, description = "This is an optional field. This field accepts single value. Will filter result as per the available report versions.")
    ),
    "getReportList" = list()
  )
)

# merge -------------------------------------------------------------------

entrata_api_request_parameters_tbl <- entrata_api_request_parameters |>
  # Convert the top-level list to a tibble
  tibble::enframe(name = "endpoint", value = "methods") |>
  # Unnest the methods
  tidyr::unnest_longer(methods) |>
  # Add the method name as a column
  dplyr::mutate(method = names(methods)) |>
  # Unnest the parameters
  tidyr::unnest_longer(methods, values_to = "parameters") |>
  # Add the parameter name as a column
  dplyr::mutate(parameter = names(parameters)) |>
  # Unnest the parameter details
  tidyr::unnest_wider(parameters, names_sep = "_") |>
  # Handle the 'multiple' field, which may not exist for all parameters
  dplyr::mutate(multiple = dplyr::coalesce(parameters_multiple, FALSE)) |>
  # Select and arrange columns
  dplyr::select(
    endpoint,
    method,
    parameter,
    type = parameters_type,
    required = parameters_required,
    multiple,
    description = parameters_description
  ) |>
  # Sort the tibble
  dplyr::arrange(endpoint, method, dplyr::desc(required), parameter)



# merge into single tibble with endpoint, method, method param information
entrata_api_request_endpoint_method_parameters <- entrata_api_request_parameters_tbl |>
  dplyr::left_join(
    y = entrata_api_request_endpoint_methods,
    by = c("endpoint", "method")
  ) |>
  dplyr::select(
    endpoint,
    method,
    important,
    parameter,
    type,
    required,
    multiple,
    description
  ) |>
  dplyr::arrange(dplyr::desc(important), endpoint, method, dplyr::desc(required))

