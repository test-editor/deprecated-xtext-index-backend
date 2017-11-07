/*******************************************************************************
 * Copyright (c) 2012 - 2017 Signal Iduna Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Signal Iduna Corporation - initial API and implementation
 * akquinet AG
 * itemis AG
 *******************************************************************************/

package org.testeditor.web.xtext.index

import com.fasterxml.jackson.databind.module.SimpleModule
import com.google.inject.Guice
import io.dropwizard.Application
import io.dropwizard.setup.Bootstrap
import io.dropwizard.setup.Environment
import java.io.File
import javax.inject.Inject
import org.eclipse.xtext.resource.IEObjectDescription
import org.testeditor.web.xtext.index.health.XtextIndexTemplateHealthCheck
import org.testeditor.web.xtext.index.persistence.GitService
import org.testeditor.web.xtext.index.resources.XtextIndexHelloWorldResource
import org.testeditor.web.xtext.index.resources.bitbucket.Push
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionDeserializer
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionSerializer

class XtextIndexHelloWorldApplication extends Application<XtextIndexHelloWorldConfiguration> {

	@Inject PushEventIndexUpdateCallback pushEventIndexCallback
	@Inject GitService gitService

	def static main(String[] args) throws Exception {
		new XtextIndexHelloWorldApplication().run(args)
	}

	override getName() {
		return "hello-world"
	}

	override initialize(Bootstrap<XtextIndexHelloWorldConfiguration> bootstrap) {
		registerCustomEObjectSerializer(bootstrap)
	}

	private def registerCustomEObjectSerializer(Bootstrap<XtextIndexHelloWorldConfiguration> bootstrap) {
		val customSerializerModule = new SimpleModule
		customSerializerModule.addSerializer(IEObjectDescription, new EObjectDescriptionSerializer())
		customSerializerModule.addDeserializer(IEObjectDescription, new EObjectDescriptionDeserializer())
		bootstrap.objectMapper.registerModule(customSerializerModule)
	}

	/**
	 * please override and provide own (language dependent) injected xtext index instance
	 */
	def protected XtextIndex getIndexInstance() {
		val injector = Guice.createInjector(#[new XtextIndexModule])
		return injector.getInstance(XtextIndex)
	}

	override run(XtextIndexHelloWorldConfiguration configuration, Environment environment) {
		val resource = new XtextIndexHelloWorldResource(configuration.template, configuration.defaultName)
		val healthCheck = new XtextIndexTemplateHealthCheck(configuration.template)
		Guice.createInjector.injectMembers(this)
		gitService.initRepository(new File(configuration.repoLocation))

		environment.jersey.register(resource)
		environment.jersey.register(new Push => [
			callback = pushEventIndexCallback => [index = indexInstance]
		])
		environment.healthChecks.register("template", healthCheck)
	}
}
