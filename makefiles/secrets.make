# -------------
# for downloading vault and running git-secret
# -------------

vault-decrypt: import-gpg-key | _verify_VAULT_PROJECT _verify_GPG_PASS
	[ ! -e build/vault ] && git clone $(VAULT_PROJECT) build/vault || :;
	cd build/vault && git secret reveal -p "$(GPG_PASS)"

import-gpg-key: hasKey := $(shell gpg --list-keys | grep $(BOT_USER) )
import-gpg-key: | _verify_GPG_PRIVATE_KEY
	@if [[ ! "$(hasKey)" && "$(GPG_PRIVATE_KEY)" ]]; then \
		echo "$(GPG_PRIVATE_KEY)" | base64 --decode | gpg -v --batch --import ; \
	fi;
# gpg above --batch doesn't ask for prompt and -v is verbose

secrets-encrypt:
	git secret hide

secrets-decrypt: 
	git secret reveal -p "$(GPG_PASS)"