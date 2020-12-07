package mlb_app

import (
	networking_v1beta1 "k8s.io/api/networking/v1beta1"
)

#IngressGCE: {
	#App: string
	#CommonLabels: {
		app:     #App
		release: #Release
		...
	}
	#Name:    string | *"\(#Release)-\(#App)"
	#Release: string

	service: metadata: annotations: {
		"beta.cloud.google.com/backend-config": "{\"default\": \"\(backendConfig.metadata.name)\"}"
		"cloud.google.com/neg":                 "{\"ingress\": true}"
	}

	ingress: networking_v1beta1.#Ingress & {
		apiVersion: "networking.k8s.io/v1beta1"
		kind:       "Ingress"
		metadata: {
			annotations: {
				"argocd.argoproj.io/sync-wave": "1"
				"kubernetes.io/ingress.class":  "gce"
				...
			}
			labels: {
				#CommonLabels
				...
			}
			name: #Name
		}
		spec: rules: [...{
			http: paths: [...{
				backend: serviceName: service.metadata.name
			}]
		}]
	}

	backendConfig: {
		apiVersion: "cloud.google.com/v1beta1"
		kind:       "BackendConfig"
		metadata: {
			labels: {
				#CommonLabels
				...
			}
			name: #Name
		}
	}
}
