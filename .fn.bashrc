
rt_outdated() {
  [[ -f package.json ]] || {
    echo "❌ No package.json found"
    return 1
  }

  echo "📦 Checking @robert.tools packages..."

  npm outdated --json --all 2>/dev/null |
    jq -r '
      to_entries[]
      | select(.key | startswith("@robert.tools/"))
      | "⬆️ \(.key): \(.value.current // "missing") → \(.value.latest) (wanted: \(.value.wanted))"
    '
}

rt_status() {
  local package="$1"

  if [[ -n "$package" ]]; then
    npm view "@robert.tools/$package" version &&
      echo "✅ Published"
  else
    npm search "@robert.tools/" --json |
      jq -r '.[] | select(.name | startswith("@robert.tools/")) | "✅ \(.name) \(.version) (published)"'
  fi
}


rt() {
  local package="$1"
  local action="$2"
  local flag="$3"

  case "$package" in
    status|monitor)
      rt_status
      return
      ;;
    outdated|check)
      rt_outdated
      return
      ;;
  esac

  case "$action" in
    status)
      rt_status "$package"
      ;;
    version)
      npm view "@robert.tools/$package" version
      ;;
    update|latest)
      npm install "${flag:---save}" "@robert.tools/$package@latest"
      ;;
    "")
      npm install --save "@robert.tools/$package"
      ;;
    *)
      npm install "${flag:---save}" "@robert.tools/$package@$action"
      ;;
  esac
}