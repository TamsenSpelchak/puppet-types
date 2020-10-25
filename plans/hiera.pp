# @summary A simple Bolt plan to deploy resources defined in hiera
#
# @param apply_prep_props [Hash]
#   A optional hash of values used by the `puppet_agent::install` task, which is invoked when Bolt runs
#   the "apply_prep" function
#
plan types::hiera(
  TargetSpec $targets,
  Hash $apply_prep_options = {},
) {
  if get_targets($targets).size < 1 {
    fail('Must specifiy one or more targets')
  }

  # Install Puppet agent and gather facts
  apply_prep([$targets], $apply_prep_options)

  # Compile the code block to a catalog and update targets, saving $results
  $results = apply($targets) {
    # Lookup classes from hiera
    lookup('classes', Array[String], 'unique').include
  }

  $results.each |$result| {
    notice($result.report)
  }
}