# Bundle ID 迁移和上架前检查清单

## 📋 更换Bundle ID后的必要调整

### 1. 🔐 Apple Developer Console 配置

#### Apple Sign In 配置
- [ ] 在 [Apple Developer Console](https://developer.apple.com/account/) 中为新Bundle ID配置 "Sign In with Apple" 能力
- [ ] 确保新的App ID开启了 "Sign In with Apple" 权限
- [ ] 配置Associated Domains（如果需要网页端Apple登录）

#### 推送通知配置（如果使用）
- [ ] 为新Bundle ID生成新的推送证书
- [ ] 更新推送服务端配置

### 2. 💳 App Store Connect 内购配置

#### 必须重新创建的内购商品
根据当前代码，需要在App Store Connect中为新Bundle ID创建以下内购商品：

**充值商品（消耗型）：**
- [ ] `pack_coin_ios_6` - 6元金币礼包 - ¥6.00 - 510个金币 **（新增）**
- [ ] `pack_coin_ios_8` - 8元金币礼包 - ¥8.00 - 680个金币 **（新增）**
- [ ] `pack_coin_ios_12` - 12元金币礼包 - ¥12.00 - 840个金币
- [ ] `pack_coin_ios_38` - 38元金币礼包 - ¥38.00 - 2660个金币  
- [ ] `pack_coin_ios_68` - 68元金币礼包 - ¥68.00 - 4760个金币
- [ ] `pack_coin_ios_98` - 98元金币礼包 - ¥98.00 - 6860个金币
- [ ] `pack_coin_ios_198` - 198元金币礼包 - ¥198.00 - 13860个金币
- [ ] `pack_coin_ios_298` - 298元金币礼包 - ¥298.00 - 20860个金币
- [ ] `pack_coin_ios_598` - 598元金币礼包 - ¥598.00 - 41860个金币

**VIP订阅商品（非消耗型）：**
- [ ] `pack_vip_38` - 1个月会员服务 尝鲜 - ¥38.00 **（新增）**
- [ ] `pack_vip_68` - 1个月会员服务 - ¥68.00
- [ ] `pack_vip_168` - 3个月会员服务 - ¥168.00  
- [ ] `pack_vip_399` - 12个月会员服务 - ¥399.00

#### 内购商品配置步骤
1. 在App Store Connect中进入你的应用
2. 转到"功能" → "App内购买项目"
3. 为每个商品点击"+"创建新的内购项目
4. 设置商品ID、价格、描述等信息
5. 等待苹果审核通过（通常24-48小时）

### 3. 🧪 测试验证

#### Apple 登录测试
- [ ] 测试设备上的Apple登录功能
- [ ] 验证登录后用户数据同步正常
- [ ] 测试退出登录功能
- [ ] 测试重新启动应用后登录状态恢复

#### 内购功能测试
- [ ] 使用沙盒测试账号测试所有充值商品
- [ ] 测试VIP订阅购买流程
- [ ] 验证购买成功后金币/VIP状态更新
- [ ] 测试购买失败和取消的处理

#### 核心功能测试
- [ ] AI聊天功能（登录/未登录状态）
- [ ] 金币消耗和VIP权限验证
- [ ] 音频播放功能
- [ ] 社区功能（发布、点赞、评论等）
- [ ] 用户数据持久化

### 4. 📱 应用配置验证

#### 当前配置检查 ✅
- [x] Info.plist - 使用动态Bundle ID `$(PRODUCT_BUNDLE_IDENTIFIER)`
- [x] Runner.entitlements - Apple Sign In配置正确
- [x] 内购商品ID已更新为正式商品ID
- [x] 无硬编码Bundle ID引用
- [x] 网络权限配置完整（Apple登录需要）

#### 版本信息
- [ ] 更新CFBundleShortVersionString版本号（当前：2.0.3）
- [ ] 更新CFBundleVersion构建号
- [ ] 确保pubspec.yaml中的版本与iOS配置一致

### 5. 🚀 上架前最终检查

#### App Store Connect配置
- [ ] 应用元数据（名称、描述、关键词）
- [ ] 应用图标和截图
- [ ] 年龄分级设置
- [ ] 内购商品全部配置并审核通过

#### 隐私和合规
- [ ] 隐私政策URL（如果收集用户数据）
- [ ] 使用条款URL
- [ ] 数据使用说明（Apple登录、设备权限等）

#### 提交审核
- [ ] 使用Archive模式构建Release版本
- [ ] 上传到App Store Connect
- [ ] 提交审核并填写审核说明

## ⚠️ 重要提醒

### Bundle ID相关的常见问题
1. **Apple登录失败**：如果Apple登录不工作，检查Developer Console中的App ID配置
2. **内购商品找不到**：确保App Store Connect中的商品ID与代码中的完全一致
3. **推送通知失效**：需要为新Bundle ID重新配置推送证书
4. **TestFlight测试**：建议先在TestFlight中测试所有功能

### 代码中无需修改的部分 ✅
- Apple登录服务实现（自动适配新Bundle ID）
- 内购服务实现（已使用正确的商品ID）
- 用户数据管理（独立于Bundle ID）
- UI和业务逻辑（不依赖Bundle ID）

### 建议的发布流程
1. 完成上述所有配置
2. 在TestFlight中进行完整测试
3. 邀请测试用户验证关键功能
4. 确认无问题后提交App Store审核

## 📞 技术支持
如果遇到以下问题：
- Apple登录配置问题 → 检查Developer Console的App ID配置
- 内购商品问题 → 检查App Store Connect中的商品状态
- 其他技术问题 → 参考苹果官方文档或联系技术支持 