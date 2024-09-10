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
    "getStatus" = list(
      NA_character_
    )
  ),
  "customers" = list(
    "getCustomers" = list(
      propertyId = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts single value for the ",
          "Property ID."
        )
      ),
      "customerIds" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for the Customer IDs."
        )
      ),
      "leaseStatusTypeIds" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for the Lease Status Type IDs."
        )
      ),
      "isAgreedToTermsOnly" = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts single value.",
          "`isAgreedToTermsOnly` returns the date when a customer has agreed to ",
          "the Terms and Conditions of Entrata resident portal."
        )
      ),
      "companyIdentificationTypeIds" = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma seperated ",
          "multiple values. company Identification type IDs."
        )
      )
    )
  ),
  "financial" = list(
    "getBudgetActuals" = list(
      propertyId = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts single value ",
          "for `propertyId`."
        )
      ),
      glTreeId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "GL Tree ID."
        )
      ),
      budgetId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "Budget ID."
        )
      ),
      postMonthFrom = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value in the ",
          "format MM/YYYY for the start month."
        )
      ),
      postMonthTo = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value in the ",
          "format MM/YYYY for the end month."
        )
      ),
      glBookTypeIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for GL Book Type IDs."
        )
      ),
      budgetStatusTypeId = list(
        type = "integer",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "Budget Status Type ID."
        )
      ),
      accountingMethod = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Accounting Method."
        )
      )
    ),
    "getBudgets" = list(
      propertyId = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "`propertyId`."
        )
      ),
      "budgetIds" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for the Budget IDs."
        )
      ),
      "budgetStatusTypeIds" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for the Budget Status Type IDs."
        )
      ),
      "fiscalYears" = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for the Fiscal Years."
        )
      )
    )
  ),
  "leases" = list(
    "getLeases" = list(
      propertyId = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      ),
      applicationId = list(
        type = "integer",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Application ID."
        )
      ),
      customerId = list(
        type = "integer",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Customer ID."
        )
      ),
      leaseStatusTypeIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for Lease Status Type IDs."
        )
      ),
      leaseIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for Lease IDs."
        )
      ),
      scheduledArCodeIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for Scheduled AR Code IDs."
        )
      ),
      unitNumber = list(
        type = "string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Unit Number."
        )
      ),
      buildingName = list(
        type = "string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Building Name."
        )
      ),
      moveInDateFrom = list(
        type = "date",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the start Move-in Date."
        )
      ),
      moveInDateTo = list(
        type = "date",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the end Move-in Date."
        )
      ),
      leaseExpiringDateFrom = list(
        type = "date",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Lease Expiring Date (start)."
        )
      ),
      leaseExpiringDateTo = list(
        type = "date",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Lease Expiring Date (end)."
        )
      ),
      moveOutDateFrom = list(
        type = "date",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Move-out Date (start)."
        )
      ),
      moveOutDateTo = list(
        type = "date",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Move-out Date (end)."
        )
      ),
      includeOtherIncomeLeases = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided, this will include leases with other income."
        )
      ),
      residentFriendlyMode = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided, this will use Resident Friendly Mode."
        )
      ),
      includeLeaseHistory = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided, lease history will be included."
        )
      ),
      includeArTransactions = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided, it will return the AR Transactions associated with the ",
          "lease."
        )
      )
    ),
    "getLeaseDetails" = list(
      propertyId = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      ),
      leaseId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Lease ID."
        )
      ),
      leaseStatusTypeIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for Lease Status Type IDs."
        )
      ),
      includeAddOns = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided, it will include lease add-ons."
        )
      ),
      includeCharge = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided, it will include charges."
        )
      )
    ),
    "getLeaseDocuments" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      ),
      leaseId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Lease ID."
        )
      ),
      externalLeaseId = list(
        type = "string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the external Lease ID."
        )
      ),
      documentIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for Document IDs."
        )
      ),
      fileTypesCode = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for file types (system codes)."
        )
      ),
      addedOnFromDate = list(
        type = "date",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Added On date (start)."
        )
      ),
      showDeletedFile = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided, it will return deleted files."
        )
      )
    ),
    "getLeaseDocumentsList" = list(
      propertyId = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      ),
      leaseId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Lease ID."
        )
      ),
      externalLeaseId = list(
        type = "string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the external Lease ID."
        )
      ),
      fileTypesCode = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for file types (system codes)."
        )
      ),
      showDeletedFile = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided, it will return deleted files."
        )
      ),
      leaseStatusTypeIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for Lease Status Type IDs."
        )
      )
    )
  ),
  "properties" = list(
    "getProperties" = list(
      propertyIds = list(
        type = "string_list",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values (concatenated into a single, comma-separated string) ",
          "representing Property IDs."
        )
      ),
      propertyLookupCode = list(
        type = "string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value for ",
          "the Property Lookup Code."
        )
      ),
      showAllStatus = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value to ",
          "show all statuses."
        )
      )
    ),
    "getFloorPlans" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      ),
      propertyFloorPlanIds = list(
        type = "string",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for Property Floor Plan IDs."
        )
      ),
      usePropertyPreferences = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. ",
          "Checks for the property settings manipulate floorplan data and ",
          "honor those settings."
        )
      ),
      includeDisabledFloorPlans = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided value is 1, then disabled floorplans will be included along ",
          "with the enabled ones."
        )
      )
    ),
    "getPropertyAddOns" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      ),
      addOnIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for the Add-On IDs."
        )
      )
    ),
    "getPropertyAnnouncements" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      ),
      announcementIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for the Announcement IDs."
        )
      )
    ),
    "getPropertyRentableItems" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      ),
      rentableItemIds = list(
        type = "integer",
        required = FALSE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts comma separated ",
          "multiple values for the Rentable Item IDs."
        )
      )
    )
  ),
  "propertyunits" = list(
    "getPropertyUnits" = list(
      propertyIds = list(
        type = "string",
        required = TRUE,
        multiple = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts comma separated ",
          "multiple values for Property IDs."
        )
      ),
      availableUnitsOnly = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided value is 1, only available units will be returned."
        )
      ),
      usePropertyPreferences = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "enabled, the Entrata setting 'Max Available Units per Floor Plan' ",
          "will be honored and the available units returned will be reduced. ",
          "Also requires using the availableUnitsOnly parameter as true (1)."
        )
      ),
      includeDisabledFloorPlans = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided value is 1, disabled floorplans will be included along with ",
          "the enabled ones."
        )
      ),
      includeDisabledUnits = list(
        type = "boolean_string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. If ",
          "provided value is 1, disabled units will be included along with the ",
          "enabled ones."
        )
      )
    ),
    "getUnitTypes" = list(
      propertyId = list(
        type = "integer",
        required = TRUE,
        multiple = FALSE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the Property ID."
        )
      )
    )
  ),
  "queue" = list(
    "getResponse" = list(
      queueId = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts single value. This node ",
          "accepts the queueId. This should be a JWT token. This token should ",
          "get generated from the getReportData(r3) version."
        )
      ),
      serviceName = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts single value. This node ",
          "accepts the service name for which the apiToken is added."
        )
      )
    )
  ),
  "reports" = list(
    "getReportDependentFilter" = list(
      reportName = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the report name. Once passed, the web service will return values ",
          "of the dependent filter for that report."
        )
      ),
      dependentFilter = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the dependent filter. The values of these filters will be returned ",
          "based on the parent fields mentioned in the 'filters' section."
        )
      ),
      filters = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value. ",
          "Parent filters are mentioned here, and based on these values, the ",
          "dependent filters will be returned."
        )
      )
    ),
    "getReportData" = list(
      reportName = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the report name. Once passed, the web service will return report ",
          "data for that report."
        )
      ),
      reportVersion = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. ",
          "Will filter results as per the available report versions."
        )
      ),
      filters = list(
        type = "object",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value. ",
          "For each report, there are filter parameters required, such as ",
          "property ID, dates, etc. You can get filters for each report ",
          "using the getReportsInfo web service."
        )
      )
    ),
    "getReportInfo" = list(
      reportName = list(
        type = "string",
        required = TRUE,
        description = stringr::str_c(
          "This is a required field. This field accepts a single value for ",
          "the report name."
        )
      ),
      reportVersion = list(
        type = "string",
        required = FALSE,
        description = stringr::str_c(
          "This is an optional field. This field accepts a single value. ",
          "Will filter results based on the available report versions."
        )
      )
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
    parameter,
    type,
    required,
    multiple,
    description
  ) |>
  dplyr::arrange(dplyr::desc(important), endpoint, method, dplyr::desc(required))

###########################

#' Is Boolean String
#'
#' @description
#' Checks if provided string represents a boolean (used by Entrata API).
#'
#' @param str Character string to check. Typically, with the Entrata API, "boolean"
#'   values are represented as quoted integers (`"0"` or `"1"`) representing
#'   `FALSE` and `TRUE`, respectively.
#'
#' @return `TRUE` if the string is a boolean string, `FALSE` otherwise.
#'
#' @export
#'
#' @examples
#' is_boolean_string("0")
is_boolean_string <- function(str) {
  str %in% c(as.character(as.integer(TRUE)), as.character(as.integer(FALSE)))
}

#' Is Integer String
#'
#' @description
#' Validate a string can be parsed into an integer.
#'
#' @param str Character string to check. Typically, with the Entrata API, "integer"
#'   parameters are actually represented as strings in the request payload.
#' @param arg For internal use only, used to capture the name of the argument.
#'
#' @return `TRUE` if the string is parseable to an integer, `FALSE` otherwise.
#'
#' @export
#'
#' @importFrom rlang caller_arg
#'
#' @examples
#' is_integer_string("1")
#' [1] TRUE
#'
#' is_integer_string("a")
#' [1] FALSE
is_integer_string <- function(str, arg = rlang::caller_arg(str)) {

  int <- NA

  tryCatch({
    int <- suppressWarnings(as.integer(str))
  }, error = function(e) {
    return(FALSE)
  })

  if (is.na(int)) { return(FALSE) } else { return(TRUE) }

}

#' @describeIn is_integer_string Is Integer String (Multi)
#'
#' @description
#' Validate a string with comma separated integers can be parsed into individual integers.
#'
#' @param str Character string to check. Typically, with the Entrata API, "multiple"
#'   values are represented as comma separated integer strings.
#' @param arg For internal use only, used to capture the name of the argument.
#'
#' @export
#'
#' @examples
#' is_integer_string_multi("1,2,3")
#' [1] TRUE
#' is_integer_string_multi("1,2,3,")
#' [1] FALSE
#' is_integer_string_multi("1,2,a,b")
#' [1] FALSE
is_integer_string_multi <- function(
  str,
  arg = rlang::caller_arg(str)
) {

  # verify a single string with comma separated integers can be parsed
  # into individual integers
  int <- NA

  # if ends with a comma, fail
  if (grepl(",$", str)) {
    cli::cli_alert_warning("{.arg {str}} ends with a comma.")
    return(FALSE)
  }

  tryCatch({
    int <- suppressWarnings(as.integer(unlist(strsplit(str, ","))))
  }, error = function(e) {
    return(FALSE)
  })

  if (any(is.na(int))) { return(FALSE) } else { return(TRUE) }

}

get_validation_function <- function(
  endpoint,
  method,
  param,
  call = rlang::caller_env(),
  arg_endpoint = rlang::caller_arg(endpoint),
  arg_method = rlang::caller_arg(method),
  arg_param = rlang::caller_arg(param)
) {

  hold <- entrata_api_request_endpoint_method_parameters |>
    dplyr::filter(endpoint == endpoint,
                  method == method,
                  parameter == param)

  if (nrow(hold) == 0) {
    cli::cli_abort(
      c(
        "No parameter {.arg arg_param} found for the {.arg arg_method} method in the {.arg arg_endpoint} endpoint."
      ),
      call = call
    )
  }

  param_type <- hold$type[[1]]
  param_multi <- hold$multiple[[1]]

  dplyr::case_when(
    param_multi ~ switch(
      param_type,
      "integer" = is_integer_string_multi,
      "string" = is_string,
      "date" = function(x) inherits(x, "Date"),
      "boolean" = is.logical,
      "boolean_string" = is_boolean_string,
      "string_list" = is.character,
      "integer_list" = is_integer_string_multi,
      stop("Unknown parameter type: ", param_type)
    ),
    TRUE ~ switch(
      param_type,
      "integer" = is_integer_string,
      "string" = is.character,
      "date" = function(x) inherits(x, "Date"),
      "boolean" = is.logical,
      "boolean_string" = is_boolean_string,
      "string_list" = is.character,
      "integer_list" = is_integer_string_multi,
      stop("Unknown parameter type: ", param_type)
    )
  )

  switch(
    param_type,
    "integer" = is_integer_string,
    "string" = is.character,
    "date" = function(x) inherits(x, "Date"),
    "boolean" = is.logical,
    "boolean_string" = is_boolean_string,
    "string_list" = is.character,
    "integer_list" = is_integer_string_multi,
    stop("Unknown parameter type: ", param_type)
  )

  switch(
    type,
    "integer" = is_integer_string,
    "string" = is.character,
    "date" = function(x) inherits(x, "Date"),
    "boolean" = is.logical,
    "boolean_string" = is_boolean_string,
    "string_list" = is.character,
    "integer_list" = is_integer_string_multi,
    stop("Unknown parameter type: ", type)
  )


  if (param_info$type == "integer" && !is.integer(param_value)) {
    cli::cli_abort(
      c(
        "Parameter {.field {param_name}} should be an integer."
      ),
      call = call
    )
  } else if (param_info$type == "string" && !is.character(param_value)) {
    cli::cli_abort(
      c(
        "Parameter {.field {param_name}} should be a string."
      ),
      call = call
    )
  } else if (param_info$type == "date" && !inherits(param_value, "Date")) {
    cli::cli_abort(
      c(
        "Parameter {.field {param_name}} should be a Date object."
      ),
      call = call
    )
  } else if (param_info$type == "boolean" && !is.logical(param_value)) {
    cli::cli_abort(
      c(
        "Parameter {.field {param_name}} should be a logical value."
      ),
      call = call
    )
  } else if (param_info$type == "boolean_string" && !is_boolean_string(param_value)) {
    cli::cli_abort(
      c(
        "Parameter {.field {param_name}} should be a boolean string."
      ),
      call = call
    )
  }
  if (!is.null(param_info$multiple) && param_info$multiple && length(param_value) > 1 && !is.vector(param_value)) {
    cli::cli_abort(
      c(
        "Parameter {.field {param_name}} should be a vector for multiple values."
      ),
      call = call
    )


}


#' @rdname entrata_request_validation
#' @export
#' @importFrom cli cli_abort
#' @importFrom rlang caller_arg caller_env
validate_entrata_request_method_params <- function(
    endpoint,
    method,
    method_params,
    arg_endpoint = rlang::caller_arg(endpoint),
    arg_method = rlang::caller_arg(method),
    arg_method_params = rlang::caller_arg(method_params),
    call = rlang::caller_env()
) {

  expected_params <- entrata_api_request_parameters[[endpoint]][[method]]

  if (is.null(expected_params)) {
    cli::cli_alert_info(
      c(
        "No parameters are expected for the {.field {method}} method."
      )
    )
  } else {
    for (param_name in names(method_params)) {
      if (!param_name %in% names(expected_params)) {
        cli::cli_alert_warning(
          c(
            "Unexpected parameter: {.field {param_name}}"
          )
        )
      } else {
        param_info <- expected_params[[param_name]]
        param_value <- method_params[[param_name]]

        if (param_info$required && is.null(param_value)) {
          cli::cli_abort(
            c(
              "Required parameter is missing: {.field {param_name}}",
              "The {.field {param_name}} parameter is required for the {.field {method}} method.",
              "Please provide a value for the {.field {param_name}} parameter."
            ),
            call = call
          )
        }

        if (!is.null(param_value)) {
          if (param_info$type == "integer" && !is.integer(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be an integer."
              ),
              call = call
            )
          } else if (param_info$type == "string" && !is.character(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a string."
              ),
              call = call
            )
          } else if (param_info$type == "date" && !inherits(param_value, "Date")) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a Date object."
              ),
              call = call
            )
          } else if (param_info$type == "boolean" && !is.logical(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a logical value."
              ),
              call = call
            )
          } else if (param_info$type == "boolean_string" && !is_boolean_string(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a boolean string."
              ),
              call = call
            )
          }
          if (!is.null(param_info$multiple) && param_info$multiple && length(param_value) > 1 && !is.vector(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a vector for multiple values."
              ),
              call = call
            )
          }
        }
      }
    }
  }
}


