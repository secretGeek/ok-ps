# Remove the 'cd' alias, so our function can take over...
if (test-path alias:cd) {
    Remove-Item alias:cd -Force
}

# We create our `cd` function as a wrapper around set-location that calls 'ok'
function cd ([parameter(ValueFromRemainingArguments = $true)][string]$Passthrough) {
  Set-Location $Passthrough
  ok # Call 'ok'
}

# Consider: do the same for pushd and popd...?
