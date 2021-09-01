resource "boundary_scope" "global" {
  global_scope = true
  scope_id     = "global"
}

resource "boundary_scope" "org" {
  name                     = "organization_one"
  description              = "My first scope!"
  scope_id                 = boundary_scope.global.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "project" {
  name                   = "project_one"
  description            = "My first scope!"
  scope_id               = boundary_scope.org.id
  auto_create_admin_role = true
}

resource "boundary_credential_store_vault" "foo" {
  name        = "vault_store"
  description = "My first Vault credential store!"
  address     = "http://127.0.0.1:8200"      # change to Vault address
  token       = "s.0ufRo6XEGU2jOqnIr7OlFYP5" # change to valid Vault token
  scope_id    = boundary_scope.project.id
}

resource "boundary_credential_library_vault" "foo" {
  name                = "foo"
  description         = "My first Vault credential library!"
  credential_store_id = boundary_credential_store_vault.foo.id
  path                = "my/secret/foo" # change to Vault backend path
  http_method         = "GET"
}

resource "boundary_host_catalog" "foo" {
  name        = "test"
  description = "test catalog"
  scope_id    = boundary_scope.project.id
  type        = "static"
}

resource "boundary_host" "foo" {
  name            = "foo"
  host_catalog_id = boundary_host_catalog.foo.id
  scope_id        = boundary_scope.project.id
  address         = "10.0.0.1"
}

resource "boundary_host" "bar" {
  name            = "bar"
  host_catalog_id = boundary_host_catalog.foo.id
  scope_id        = boundary_scope.project.id
  address         = "10.0.0.1"
}

resource "boundary_host_set" "foo" {
  name            = "foo"
  host_catalog_id = boundary_host_catalog.foo.id

  host_ids = [
    boundary_host.foo.id,
    boundary_host.bar.id,
  ]
}

resource "boundary_target" "foo" {
  name         = "foo"
  description  = "Foo target"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.project.id
  host_set_ids = [
    boundary_host_set.foo.id
  ]
  application_credential_library_ids = [
    boundary_credential_library_vault.foo.id
  ]
}
