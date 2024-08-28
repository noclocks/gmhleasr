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

# used endpoints/methods --------------------------------------------------

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
