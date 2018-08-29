#
# demo Delivery Servers
#

output "demo_delivery_vms_ips" {
  value = "${module.demo_delivery.public_ips}"
}

output "demo_delivery_vms_ips_private" {
  value = "${module.demo_delivery.private_ips}"
}

output "demo_delivery_vms_fqdn_custom" {
  value = "${module.demo_delivery.fqdn_custom}"
}

output "demo_delivery_agw_fqdn_custom" {
  value = "${module.demo_delivery.agw_fqdn_custom}"
}

output "demo_delivery_agw_fqdn" {
  value = "${module.demo_delivery.agw_fqdn}"
}

#
# demo SQL Servers
#

output "demo_sql_fqdn" {
  value = "${module.demo_sql.fqdn}"
}

output "demo_sql_fqdn_custom" {
  value = "${module.demo_sql.fqdn_custom}"
}

#
# Redis instances
#


/*

output "redis_fqdn_custom" {
  value = "${module.redis.fqdn_custom}"
}

output "redis_fqdn" {
  value = "${module.redis.fqdn}"
}

output "redis_port" {
  value = "${module.redis.port}"
}

output "redis_ssl_port" {
  value = "${module.redis.ssl_port}"
}

output "redis_primary_access_key" {
  value = "${module.redis.primary_access_key}"
}

output "redis_secondary_access_key" {
  value = "${module.redis.secondary_access_key}"
}
*/

