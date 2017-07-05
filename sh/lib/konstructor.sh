declare -r CURL_CMD="curl -s --connect-timeout 3"

cnameCreateOrUpdate() {
  RECORD="${1}"
  ZONE="${2}"
  FQDN="${1}.${2}"
  ALBDNS="${3}"
  TTL="${4}"

  if [[ "$(cnameExist ${FQDN})" ]]; then
    if [[ "$(cnameUpToDate ${FQDN} ${ALBDNS})" ]]; then
      info "Cname ${FQDN} is up to date"
    else
      info "Cname ${FQDN} requires update"
      deleteCname ${ZONE} ${RECORD}
      createCname ${ZONE} ${RECORD} ${ALBDNS} ${TTL}
    fi
  else
    warn "CNAME ${FQDN} does not exist. Creating CNAME."
    createCname ${ZONE} ${RECORD} ${ALBDNS} ${TTL}
  fi
}

cnameExist() {
  #ARG1: cname to lookup
  #returns: true if cname exists
  host -t cname $1 &>/dev/null && echo "true"

}

cnameUpToDate() {
  host -t cname $1 | grep -o $2 && echo "true"
}

createCname() {
  info "Creating record zone: $1, name: $2, record: $3, ttl: $4"
  python $(dirname $0)/../python/create-dns -z $1 -n $2 -r $3 -t $4 -k ${ARGS[--dynkey]} || errorAndExit "Failed to create CNAME for $2.$1 Exit 1." 1
}

deleteCname() {
  python $(dirname $0)/../python/delete-dns -z $1 -n $2 -k ${ARGS[--dynkey]} || errorAndExit "Failed to delete CNAME for $2.$1 Exit 1." 1
}
