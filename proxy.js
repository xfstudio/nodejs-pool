const Proxy = require("coin-hive-stratum");
const proxy = new Proxy({
  host: "miner.cdxfkj.cn",
  port: 5555
});
proxy.listen(8892);