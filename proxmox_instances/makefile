.PHONY: deploy configure init plan

init:
	cd $(INSTANCE) && (source ../.env; terragrunt init)

plan:
	cd $(INSTANCE) && (source ../.env; terragrunt plan)

apply:
	cd $(INSTANCE) && (source ../.env; terragrunt apply)

configure:
	cd $(INSTANCE) && TF_TERRAGRUNT=Y ansible-playbook -K -i ../iac/ansible-terraform-inventory_v0.4.0 main.yml

requirements:
	ansible-galaxy role install -r requirements.yml