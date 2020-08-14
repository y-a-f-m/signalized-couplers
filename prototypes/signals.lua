BLUE_BACKGROUND = "__base__/graphics/icons/signal/signal_white.png"

data:extend({
  {
    type = "item-subgroup",
    name = "couple-signals",
    group = "signals",
    order = "g"
  },
  {
    type = "virtual-signal",
    name = "signal-couple",
    icons =
    {
      {icon = BLUE_BACKGROUND},
      {icon = "__Signalized_Couplers__/graphics/signal/couple.png"}
    },
    icon_size = 64,
    subgroup = "couple-signals",
    order = "a-a"
  },
  {
    type = "virtual-signal",
    name = "signal-uncouple",
    icons =
    {
      {icon = BLUE_BACKGROUND},
      {icon = "__Signalized_Couplers__/graphics/signal/uncouple.png"}
    },
    icon_size = 64,
    subgroup = "couple-signals",
    order = "a-b"
  }
})