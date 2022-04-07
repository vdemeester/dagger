setup() {
    load '../../../../bats_helpers'

    common_setup
}

@test "tekton" {
    dagger "do" -p ./task.cue test
}