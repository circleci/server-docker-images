{{/* vim: set filetype=mustache: */}}

{{/*
Generate backend entry that is compatible with all Kubernetes API versions.

Usage:
{{ include "common-v1.ingress.backend" (dict "serviceName" "backendName" "servicePort" "backendPort" "context" $) }}

Params:
  - serviceName - String. Name of an existing service backend
  - servicePort - String/Int. Port name (or number) of the service. It will be translated to different yaml depending if it is a string or an integer.
  - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "common-v1.ingress.backend" -}}
{{- $apiVersion := (include "common-v1.capabilities.ingress.apiVersion" .context) -}}
{{- if or (eq $apiVersion "extensions/v1beta1") (eq $apiVersion "networking.k8s.io/v1beta1") -}}
serviceName: {{ .serviceName }}
servicePort: {{ .servicePort }}
{{- else -}}
service:
  name: {{ .serviceName }}
  port:
    {{- if typeIs "string" .servicePort }}
    name: {{ .servicePort }}
    {{- else if or (typeIs "int" .servicePort) (typeIs "float64" .servicePort) }}
    number: {{ .servicePort | int }}
    {{- end }}
{{- end -}}
{{- end -}}

{{/*
Print "true" if the API pathType field is supported
Usage:
{{ include "common-v1.ingress.supportsPathType" . }}
*/}}
{{- define "common-v1.ingress.supportsPathType" -}}
{{- if (semverCompare "<1.18-0" (include "common-v1.capabilities.kubeVersion" .)) -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if the ingressClassname field is supported
Usage:
{{ include "common-v1.ingress.supportsIngressClassname" . }}
*/}}
{{- define "common-v1.ingress.supportsIngressClassname" -}}
{{- if semverCompare "<1.18-0" (include "common-v1.capabilities.kubeVersion" .) -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed
certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
Usage:
{{ include "common-v1.ingress.certManagerRequest" ( dict "annotations" .Values.path.to.the.ingress.annotations ) }}
*/}}
{{- define "common-v1.ingress.certManagerRequest" -}}
{{ if or (hasKey .annotations "cert-manager.io/cluster-issuer") (hasKey .annotations "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}
