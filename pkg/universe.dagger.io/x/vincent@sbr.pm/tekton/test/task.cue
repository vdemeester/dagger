package tekton

import (
	"dagger.io/dagger"
	// "dagger.io/dagger/core"

	"universe.dagger.io/x/vincent@sbr.pm/tekton"
)

dagger.#Plan & {
	actions: test: task: {
	// Test: inline task tekton.#Task
		inline: {
			task: tekton.#Task & {
				definition: contents: #"""
				apiVersion: tekton.dev/v1beta1
				kind: Task
				metadata:
				  name: git-clone
				spec:
				  steps:
				  - name: clone
				    image: gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.21.0
				    command: ["/ko-app/git-init"]
				    args: ["-url=https://github.com/vdemeester/buildkit-tekton", "-revision=main", "-path=/workspace/foo"]
				  - name: ls
				    image: bash:latest
				    command: ["ls", "-l"]
				    args: ["/", "/workspace"]
				"""#
			}
		}
	}
}
