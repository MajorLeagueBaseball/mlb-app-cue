package mlb_app

import (
	"k8s.io/api/core/v1"
	apps_v1 "k8s.io/api/apps/v1"
	autoscaling_v2beta1 "k8s.io/api/autoscaling/v2beta1"
	batch_v1 "k8s.io/api/batch/v1"
	policy_v1beta1 "k8s.io/api/policy/v1beta1"
)

#BaseApp: {
	#App: string
	#CommonLabels: {
		app:     #App
		release: #Release
		...
	}
	#Name:    string | *"\(#Release)-\(#App)"
	#Release: string

	_env: {...}

	podDisruptionBudget: policy_v1beta1.#PodDisruptionBudget & {
		apiVersion: "policy/v1beta1"
		kind:       "PodDisruptionBudget"
		metadata: {
			labels: {
				#CommonLabels
				...
			}
			name: #Name
		}
		spec: {
			maxUnavailable: string | *"25%"
			selector: matchLabels: deployment.spec.template.metadata.labels
		}
	}

	serviceAccount: v1.#ServiceAccount & {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: {
			labels: {
				#CommonLabels
				...
			}
			name: #Name
		}
	}

	service: v1.#Service & {
		apiVersion: "v1"
		kind:       "Service"
		metadata: {
			labels: {
				#CommonLabels
				...
			}
			name: #Name
		}
		spec: selector: deployment.spec.template.metadata.labels
	}

	deployment: apps_v1.#Deployment & {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			labels: {
				#CommonLabels
				...
			}
			name: #Name
		}
		spec: {
			revisionHistoryLimit: 4
			selector: matchLabels: {
				#CommonLabels
				...
			}
			template: {
				metadata: labels: {
					#CommonLabels
					...
				}
				spec: {
					containers: [{
						name: #App
						env: [
							for k, v in _env {
								name:  k
								value: v
							},
						]
					}, ...]
					serviceAccountName: serviceAccount.metadata.name
				}
			}
		}
	}

	horizontalPodAutoscaler?: autoscaling_v2beta1.#HorizontalPodAutoscaler & {
		apiVersion: "autoscaling/v2beta1"
		kind:       "HorizontalPodAutoscaler"
		metadata: {
			labels: {
				#CommonLabels
				...
			}
			name: #Name
		}
		spec: {
			minReplicas: int | *1
			scaleTargetRef: {
				apiVersion: deployment.apiVersion
				kind:       deployment.kind
				name:       deployment.metadata.name
			}
		}
	}

	job?: batch_v1.#Job & {
		apiVersion: "batch/v1"
		kind:       "Job"
		metadata: {
			labels: {
				#CommonLabels
				...
			}
			name: #Name
		}
	}
}
