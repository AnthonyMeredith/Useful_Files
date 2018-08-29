#
# Provision sql db
#

resource "null_resource" "provision_sql" {
  connection {
    host     = "${element(module.demo_delivery.public_ips,0)}"
    type     = "winrm"
    user     = "${var.webserver_username}"
    password = "${var.webserver_password}"
  }

  provisioner "file" {
    source      = "sql"
    destination = "C:/"
  }

  provisioner "file" {
    content     = "${data.template_file.artsql.rendered}"
    destination = "C:\\artsql.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -sta -ExecutionPolicy Unrestricted -command \"c:\\artsql.ps1\"",
    ]
  }
  depends_on = ["module.demo_delivery"]
}

data "template_file" "artsql" {
  template = "${file("sql/artsql.ps1")}"

  vars {
    sql_host = "${module.demo_sql.fqdn}"
    sql_db   = "art-db"
    sql_user = "${var.sql_user}"
    sql_pass = "${var.sql_password}"
  }
}

#
# Provision delivery farm
#

resource "null_resource" "provision_delivery" {
  count = "${var.demo_delivery_count}"

  connection {
    host     = "${element(module.demo_delivery.public_ips,count.index)}"
    type     = "winrm"
    user     = "${var.webserver_username}"
    password = "${var.webserver_password}"
  }

  provisioner "file" {
    source      = "artweb/"
    destination = "C:/"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -sta -ExecutionPolicy Unrestricted -command \"c:\\artweb.ps1\"",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.webconfig.rendered}"
    destination = "C:\\inetpub\\wwwroot\\Web.config"
  }
  depends_on = ["null_resource.provision_sql"]
}

data "template_file" "webconfig" {
  template = "${file("artweb/Web.config")}"

  vars {
    sql_host = "${module.demo_sql.fqdn}"
    sql_db   = "art-db"
    sql_user = "${var.sql_user}"
    sql_pass = "${var.sql_password}"
  }
}