# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
use_frameworks!

def share_pods
  pod 'Firebase'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
end

##### Dev
target 'SocialLite_Dev' do
  share_pods

  target 'SocialLiteTests' do
    inherit! :search_paths
    # Pods for testing
    
  end

  target 'SocialLiteUITests' do
    # Pods for testing
  end
end

##### Production
target 'SocialLite_Production' do
  share_pods
end

