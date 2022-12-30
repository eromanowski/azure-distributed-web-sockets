// Declare variables
param appGWName string
param appGWSku string
param appGWInstanceCount int
param appGWTier string
param appGWRoutingRule string

// Create the Application Gateway resource
resource appGW 'Microsoft.Network/applicationGateways@2019-11-01' = {
  name: appGWName
  location: resourceGroup().location
  sku: {
    name: appGWSku
    tier: appGWTier
    capacity: appGWInstanceCount
  }
  gatewayIPConfigurations: [
    {
      name: "${appGWName}-gwipconfig"
      subnet: {
        id: virtualNetwork().subnets[0].id
      }
    }
  ]
  frontendIPConfigurations: [
    {
      name: "${appGWName}-frontendip"
      publicIPAddress: {
        id: publicIPAddress().id
      }
    }
  ]
  frontendPorts: [
    {
      name: "${appGWName}-frontendport-80"
      port: 80
    }
  ]
  backends: [
    {
      name: "${appGWName}-backend-pool"
      backendAddresses: [
        {
          ipAddress: "10.0.0.1"
        },
        {
          ipAddress: "10.0.0.2"
        }
      ]
    }
  ]
  backendHttpSettingsCollection: [
    {
      name: "${appGWName}-http-settings"
      port: 80
      protocol: "Http"
      cookieBasedAffinity: "Disabled"
      requestTimeout: 30
      probe: {
        id: "${appGWName}-http-settings-probe"
      }
    }
  ]
  probes: [
    {
      name: "${appGWName}-http-settings-probe"
      protocol: "Http"
      host: "localhost"
      path: "/health"
      interval: 15
      timeout: 5
      unhealthyThreshold: 3
      pickHostNameFromBackendHttpSettings: true
    }
  ]
  httpListeners: [
    {
      name: "${appGWName}-http-listener"
      frontendIPConfiguration: {
        id: appGW.frontendIPConfigurations[0].id
      }
      frontendPort: {
        id: appGW.frontendPorts[0].id
      }
      protocol: "Http"
      sslCertificate: null
    }
  ]
  urlPathMaps: [
    {
      name: "${appGWName}-url-path-map"
      defaultBackendAddressPool: {
        id: appGW.backends[0].id
      }
      defaultBackendHttpSettings: {
        id: appGW.backendHttpSettingsCollection[0].id
      }
      paths: [
        {
          path: "/*"
          backendAddressPool: {
            id: appGW.backends[0].id
          }
          backendHttpSettings: {
            id: appGW.backend
HttpSettingsCollection[0].id
          }
        }
      ]
    }
  ]
  requestRoutingRules: [
    {
      name: appGWRoutingRule
      ruleType: "Basic"
      httpListener: {
        id: appGW.httpListeners[0].id
      }
      backendAddressPool: {
        id: appGW.backends[0].id
      }
      backendHttpSettings: {
        id: appGW.backendHttpSettingsCollection[0].id
      }
      urlPathMap: {
        id: appGW.urlPathMaps[0].id
      }
    }
  ]
}

# Output the Application Gateway resource ID
output appGWResourceId string = resourceId(appGW)
