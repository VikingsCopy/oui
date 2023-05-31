local M = {}

local iwinfo = require 'iwinfo'
local ubus = require 'eco.ubus'

function M.stations()
    local status = ubus.call('network.wireless', 'status', {}) or {}

    local stations = {}

    for dev_name, dev in pairs(status) do
        if dev.up then
            local typ = iwinfo.type(dev_name)
            if not typ then
                break
            end

            local iw = iwinfo[typ]

            local band = dev.config.band

            for _, ifs in ipairs(dev.interfaces) do
                local ifname = ifs.ifname
                local assoclist = iw.assoclist(ifname)

                for macaddr, sta in pairs(assoclist) do
                    stations[#stations + 1] = {
                        macaddr = macaddr,
                        ifname = ifname,
                        band = band,
                        signal = sta.signal,
                        noise = sta.noise,
                        rx_rate = {
                            rate = sta.rx_rate,
                            mhz = sta.rx_mhz,
                            mcs = sta.rx_mcs,
                            ht = sta.rx_ht,
                            vht = sta.rx_vht,
                            he = sta.rx_he,
                            nss = sta.rx_nss,
                            short_gi = sta.rx_short_gi,
                            he_gi = sta.rx_he_gi,
                            he_dcm = sta.rx_he_dcm
                        },
                        tx_rate = {
                            rate = sta.tx_rate,
                            mhz = sta.tx_mhz,
                            mcs = sta.tx_mcs,
                            ht = sta.tx_ht,
                            vht = sta.tx_vht,
                            he = sta.tx_he,
                            nss = sta.tx_nss,
                            short_gi = sta.tx_short_gi,
                            he_gi = sta.tx_he_gi,
                            he_dcm = sta.tx_he_dcm
                        }
                    }
                end
            end
        end
    end

    return { stations = stations }
end

return M
