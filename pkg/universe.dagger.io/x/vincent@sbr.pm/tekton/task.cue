package tekton

import (
	"encoding/yaml"
	"list"

	"dagger.io/dagger"
	"dagger.io/dagger/core"
	// "universe.dagger.io/alpine"
	"universe.dagger.io/docker"
)

#Param: {
	name:  string
	value: string
}

#Task: {
	params?: [...#Param]
	definition: {
		reference: docker.#Ref
		task:      string

		_image: docker.#Pull & {
			source: reference
		}
		_readTask: core.#ReadFile & {
			input: _image.output.rootfs
			path:  task
		}
		_contents: _readTask.contents
	} | {
		contents:  string
		_contents: contents
	}

	_tasks: yaml.Unmarshal(definition._contents)
	_dag: {
		for idx, step in _tasks.spec.steps {
			"\(idx)": {

				_image: docker.#Pull & {
					source: step.image
				}
				_run: docker.#Run & {
					// if idx > 0 {
					//  _output: _dag["\(idx-1)"].output
					//  input:   _output
					// }
					input:      _image.output
					always:     true
					entrypoint: step.command
					command: {
						name: step.args[0]
						args: list.Drop(step.args, 1)
					}
					// if step.env != _|_ {
					// for k, v in step.env {
					//  env: v.name: v.value
					// }
					// }
					mounts: {
						"tekton": {
							contents: dagger.#Scratch
							dest:     "/tekton"
						}
						if idx == 0 {
							"workspace": {
								contents: dagger.#Scratch
								dest:     "/workspace"
							}
						}
						if idx > 0 {
							_workspacesubdir: core.#Subdir & {
								input: _dag["\(idx-1)"]._run.output.rootfs
								path:  "/workspace"
							}
							"workspace": {
								contents: _workspacesubdir.output
								dest:     "/workspace"
							}
							"previous": {
								contents: _dag["\(idx-1)"]._run.output.rootfs
								dest:     "/previous"
							}
						}
					}
				}
			}
		}
	}
}
