package mlb_app

import (
	"strings"
)

#CloudSQLProxy: {
	#CloudSQLInstances: [...string]
	#ProxyTermTimeout: int | *0

	deployment: spec: template: spec: {
		containers: [{}, {
			command: ["/cloud_sql_proxy", "-term_timeout=\(#ProxyTermTimeout)", ...string]
			env: [{
				name:  "GOOGLE_APPLICATION_CREDENTIALS"
				value: "/secrets/key.json"
			}, {
				name:  "INSTANCES"
				value: "\(strings.Join(#CloudSQLInstances, ","))"
			}, ...]
			image: string | *"gcr.io/cloudsql-docker/gce-proxy:1.19.1"
			name:  "cloudsql-proxy"
			resources: {
				limits: memory: string | *"132M"
				requests: {
					cpu:    string | *"12m"
					memory: string | *"132M"
				}
			}
			securityContext: runAsNonRoot: true
			volumeMounts: [{
				mountPath: "/secrets"
				name:      "credentials-volume"
				readOnly:  true
			}, ...]
		}, ...]
		volumes: [{
			name: "credentials-volume"
			secret: secretName: "cloudsql-proxy"
		}, ...]
	}
}
