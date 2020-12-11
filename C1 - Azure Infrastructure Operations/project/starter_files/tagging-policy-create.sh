# create new policy definition
az policy definition create \
  --name tagging-policy \
  --description "This policy denies deployment of new Resource unless at least one tag is created." \
  --display-name "Deny creation of Resources with no tags" \
  --mode "Indexed" \
  --rules tagging-policy-rule.json \
  --subscription "707a2a01-f589-4fbf-8753-b278612b58ef"

# create policy definition assignment
az policy assignment create \
  --name tagging-policy-assignment \
  --policy tagging-policy \
  --scope "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef" \
  --display-name "Assignment of tagging-policy to all Resources in the subscription." \
  --sku "free"