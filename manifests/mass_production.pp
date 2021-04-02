# Mass production of resources
#
# @api private
class rabbitmq::mass_production {
  create_resources('rabbitmq_plugin', $rabbitmq::plugins)
  create_resources('rabbitmq_user', $rabbitmq::users)
  create_resources('rabbitmq_vhost', $rabbitmq::vhosts)

  $merged_queues = $rabbitmq::queues + $rabbitmq::vhosts.reduce( {}) |Hash $_memo1, Array $_vhost_params| {
    $_vhost_name = $_vhost_params[0]
    $_memo1 + $rabbitmq::default_queues.reduce( {}) |Hash $_memo2, Array $_queue_params| {
      $_memo2 + {
        "${_queue_params[0]}@${_vhost_name}" => $_queue_params[1],
      }
    }
  }

  $merged_exchanges = $rabbitmq::exchanges + $rabbitmq::vhosts.reduce( {}) |Hash $_memo1, Array $_vhost_params| {
    $_vhost_name = $_vhost_params[0]
    $_memo1 + $rabbitmq::default_exchanges.reduce( {}) |Hash $_memo2, Array $_exchange_params| {
      $_memo2 + {
        "${_exchange_params[0]}@${_vhost_name}" => $_exchange_params[1],
      }
    }
  }

  $merged_bindings = $rabbitmq::bindings + $rabbitmq::vhosts.reduce( {}) |Hash $_memo1, Array $_vhost_params| {
    $_vhost_name = $_vhost_params[0]
    $_memo1 + $rabbitmq::default_bindings.reduce( {}) |Hash $_memo2, Array $_binding_params| {
      $_memo2 + $rabbitmq::merged_queues.reduce( {}) |Hash $_memo3, Array $_queue_params| {
        $_queue_name = $_queue_params[0]
        $_memo3 + $rabbitmq::merged_exchanges.reduce( {}) |Hash $_memo4, Array $_exchange_params| {
          $_memo4 + {
            "${_binding_params[0]}@${_queue_name}@${_vhost_name}" => $_binding_params[1] ,
          }
        }
      }
    }
  }

  $merged_user_permissions = $rabbitmq::user_permissions + $rabbitmq::vhosts.reduce( {}) |Hash $_memo1, Array $_vhost_params| {
    $_vhost_name = $_vhost_params[0]
    $_memo1 + $rabbitmq::default_user_permissions.reduce( {}) |Hash $_memo2, Array $_user_permission_params| {
      $_memo2 + {
        "${_user_permission_params[0]}@${_vhost_name}" => $_user_permission_params[1],
      }
    }
  }

  $merged_policies = $rabbitmq::policies + $rabbitmq::vhosts.reduce( {}) |Hash $_memo1, Array $_vhost_params| {
    $_vhost_name = $_vhost_params[0]
    $_memo1 + $rabbitmq::default_policies.reduce( {}) |Hash $_memo2, Array $_policy_params| {
      $_memo2 + {
        "${_policy_params[0]}@${_vhost_name}" => $_policy_params[1],
      }
    }
  }

  create_resources('rabbitmq_binding', $merged_bindings)
  create_resources('rabbitmq_exchange', $merged_exchanges)
  create_resources('rabbitmq_policy', $merged_policies)
  create_resources('rabbitmq_queue', $merged_queues)
  create_resources('rabbitmq_user_permissions', $merged_user_permissions)

  Rabbitmq_vhost <| $tag == $name |>
  -> Rabbitmq_user <| $tag == $name |>
  -> Rabbitmq_user_permissions <| $tag == $name |>
  -> Rabbitmq_policy <| $tag == $name |>
  -> Rabbitmq_exchange <| $tag == $name |>
  -> Rabbitmq_queue <| $tag == $name |>
  -> Rabbitmq_binding <| $tag == $name |>
}
