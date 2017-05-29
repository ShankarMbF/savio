#!/usr/bin/env groovy
 
/**
        * Jenkinsfile for Jenkins2 Pipeline
*/
 
import hudson.model.*
import hudson.EnvVars
import groovy.json.JsonSlurperClassic
import groovy.json.JsonBuilder
import groovy.json.JsonOutput
import java.net.URL

node ('iOS_Slave_London_Office') {

	stage ('Checkout and Setup') {	

		deleteDir()
		
		checkout scm

		sh "sed -i -e 's|<string>bdleVer</string>|<string>${env.BUILD_NUMBER}</string>|g' ${env.Project_Name}/Info.plist"
		sh "sed -i -e 's|<string>bdleName</string>|<string>${env.CFBundleName}</string>|g' ${env.Project_Name}/Info.plist"
		sh "sed -i -e 's|<string>bdleShrtVer</string>|<string>${env.CFBundleShortVersionString}</string>|g' ${env.Project_Name}/Info.plist"
		sh "sed -i -e 's/MyApplePass/${env.MyApplePass}/g' fastlane/Fastfile"
		sh "sed -i -e 's/crshapitoken/${env.CRASHLYTICS_API_TOKEN}/g' fastlane/Fastfile"
		sh "sed -i -e 's/crshbuildsecret/${env.CRASHLYTICS_BUILD_SECRET}/g' fastlane/Fastfile"
		sh "sed -i -e 's/crshgrp/${env.CRASHLYTICS_GROUP}/g' fastlane/Fastfile"
		sh "sed -i -e 's/provisngProfile/${env.Provisioning_Name}/g' fastlane/Fastfile"
	}
	
	stage ('Lint') {
		sh 'cd fastlane; fastlane ios lint;'
		checkstyle canComputeNew: false, defaultEncoding: '', healthy: '', pattern: 'reports/checkstyle-report.xml', unHealthy: ''
		
//		def scannerHome = tool 'sonarScanner';
//		withSonarQubeEnv {
//		  sh "${scannerHome}/bin/sonar-runner"
//		}
	}
	
	stage ('Test') {
//		sh 'fastlane ios test'
	}
	
	stage ('POD install') {
//		sh "rm -Rf Pods; pod install"
//		sh "pod update"
	}
	
	stage ('Build and Deploy to Crashlytics') {
		//def build_number = env.BUILD_NUMBER
		//sh "fastlane build build_number:${build_number}"
		
		sh "fastlane ios ${env.Lane} ProjectName:${env.Project_Name} --verbose"
	}
	
	stage ('sonar Anaysis') {
//		sh "fastlane ios sonarAnalysis"
//		sh "fastlane ios metrics"
	}
	
//	stage ('Deploy') {
//		archive 'reports/, dist/'
//		sh '/usr/local/bin/fastlane ios deploy'
//    }
}