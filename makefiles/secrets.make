# -------------
# for downloading vault and running git-secret
# -------------
GIT_SECRET_PATH := $(BUILD_BIN)/git-secret
GIT_SECRET_SH := $(GIT_SECRET_PATH)/git-secret

# on demand clone and install of git-secret
$(GIT_SECRET_SH):
	@git clone https://github.com/sobolevn/git-secret.git $(GIT_SECRET_PATH) -b v0.4.0 --depth 1
	@cd $(GIT_SECRET_PATH) && make build

vault-decrypt: import-gpg-key $(GIT_SECRET_SH) | _verify_VAULT_PROJECT _verify_GPG_PASS
	[ ! -e build/vault ] && git clone $(VAULT_PROJECT) build/vault || :;
	cd build/vault && $(GIT_SECRET_SH) reveal -p "$(GPG_PASS)"

import-gpg-key: hasKey = $(shell gpg --list-keys | grep $(BOT_USER) )
import-gpg-key: | _verify_GPG_PRIVATE_KEY
	@if [[ ! "$(hasKey)" && "$(GPG_PRIVATE_KEY)" ]]; then \
		echo "$(GPG_PRIVATE_KEY)" | base64 --decode | gpg -v --batch --import ; \
	fi;
# gpg above --batch doesn't ask for prompt and -v is verbose

git-secret-version: $(GIT_SECRET_SH)
	@$(GIT_SECRET_SH) --version

secrets-encrypt:
	@$(GIT_SECRET_SH) hide

secrets-decrypt: 
	@$(GIT_SECRET_SH) reveal -p "$(GPG_PASS)"