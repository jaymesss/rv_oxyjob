Config = {}
Config.CoreName = "qb-core"
Config.FuelResource = "cdn-fuel" --LegacyFuel or any other supported
Config.NewListingTime = 30 --In Minutes
Config.DownPayment = 200
Config.OxyItemName = 'oxy_pill'
Config.OxyBottleName = 'oxy_bottle'
Config.PlasticItemName = 'plastic'
Config.OxysPerTrunk = math.random(80, 240)
Config.OxysPerBottle = 10
Config.PlasticPerBottle = 2
Config.SellPricePerBottle = math.random(300, 400)
Config.ClientsRobChance = 25
Config.GlobalClientCooldownMinutes = 15
Config.ClienteleList = {
    Ped = {
        Coords = vector4(-1706.87, -453.45, 41.65, 147.43),
        Model = 'a_m_y_vinewood_03'
    },
    Target = {
        Coords = vector3(-1706.87, -453.45, 42.65),
        Heading = 320,
        Label = "View Clientele"
    }
}
Config.JobListing = {
    Ped = {
        Coords = vector4(-55.5, 6392.84, 30.49, 48.91),
        Model = 'a_m_m_skidrow_01'
    },
    Target = {
        Coords = vector3(-55.5, 6392.84, 31.49),
        Heading = 217,
        Label = "View Job Listings"
    }
}
Config.Scales = {
    Target = {
        Coords = vector3(92.85, 3754.51, 41.6),
        Heading = 65,
        Label = "Put Oxys Into Bottle",
        RequireItem = true
    }
}
Config.JobLocations ={
    {
        Name = 'Route 68 Job',
        Van = {
            Coords = vector4(-24.07, 2874.97, 59.15, 152.61),
            Model = 'speedo'
        },
        Shooters = {
            {
                Coords = vector4(-29.91, 2871.98, 58.37, 159.62),
                Model = 'a_m_m_afriamer_01',
                Weapon = 'WEAPON_COMBATPISTOL',
                Health = 2000,
                Keys = true,
            },
            {
                Coords = vector4(-49.0, 2871.63, 57.96, 226.37),
                Model = 'a_m_m_beach_01',
                Weapon = 'WEAPON_COMBATPISTOL',
                Health = 2000,
                Keys = false,
            },
            {
                Coords = vector4(-34.66, 2869.85, 58.6, 170.85),
                Model = 'a_m_m_rurmeth_01',
                Weapon = 'WEAPON_COMBATPISTOL',
                Health = 2000,
                Keys = false,
            },
            {
                Coords = vector4(-29.22, 2859.36, 58.68, 142.1),
                Model = 'a_m_m_salton_03',
                Weapon = 'WEAPON_COMBATPISTOL',
                Health = 2000,
                Keys = false,
            }
        },
        Respray = {
            Coords = vector3(130.14, -1938.78, 20.62),
        }
    }
}
Config.Clients = {
    {
        TradePoint = {
            Coords = vector3(1411.85, -1500.84, 59.77)
        },
        Peds = {
            {
                Coords = vector4(1411.17, -1499.35, 59.72, 201.78),
                Model = 'a_m_m_afriamer_01',
                Weapon = 'WEAPON_COMBATPISTOL',
                Health = 2000,
                Main = true,
            },
            {
                Coords = vector4(1412.69, -1496.37, 59.89, 203.55),
                Model = 'a_m_m_beach_01',
                Weapon = 'WEAPON_COMBATPISTOL',
                Health = 2000,
                Main = false,
            },
            {
                Coords = vector4(1410.43, -1492.77, 60.65, 156.26),
                Model = 'a_m_m_rurmeth_01',
                Weapon = 'WEAPON_COMBATPISTOL',
                Health = 2000,
                Main = false,
            },
            {
                Coords = vector4(1405.85, -1498.4, 59.78, 230.46),
                Model = 'a_m_m_salton_03',
                Weapon = 'WEAPON_COMBATPISTOL',
                Health = 2000,
                Main = false,
            }
        }
    }
}