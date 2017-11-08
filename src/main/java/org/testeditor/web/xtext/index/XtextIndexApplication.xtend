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
import com.google.inject.Injector
import io.dropwizard.Application
import io.dropwizard.setup.Bootstrap
import io.dropwizard.setup.Environment
import java.io.File
import javax.inject.Inject
import org.eclipse.xtext.resource.IEObjectDescription
import org.slf4j.LoggerFactory
import org.testeditor.web.xtext.index.persistence.GitService
import org.testeditor.web.xtext.index.resources.bitbucket.Push
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionDeserializer
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionSerializer

class XtextIndexApplication extends Application<XtextIndexConfiguration> {

	protected static val logger = LoggerFactory.getLogger(XtextIndexApplication)

	@Inject PushEventIndexUpdateCallback pushEventIndexCallback
	@Inject GitService gitService
	@Inject FileBasedXtextIndexFiller indexFiller

	def static main(String[] args) throws Exception {
		new XtextIndexApplication().run(args)
	}

	override getName() {
		return "xtext-index-service"
	}

	override initialize(Bootstrap<XtextIndexConfiguration> bootstrap) {
		registerCustomEObjectSerializer(bootstrap)
	}

	private def registerCustomEObjectSerializer(Bootstrap<XtextIndexConfiguration> bootstrap) {
		val customSerializerModule = new SimpleModule
		customSerializerModule.addSerializer(IEObjectDescription, new EObjectDescriptionSerializer)
		customSerializerModule.addDeserializer(IEObjectDescription, new EObjectDescriptionDeserializer)
		bootstrap.objectMapper.registerModule(customSerializerModule)
	}

	/**
	 * please override and provide own (language dependent) injected xtext index instance
	 */
	protected def XtextIndex getIndexInstance() {
		val injector = Guice.createInjector(#[new XtextIndexModule])
		return injector.getInstance(XtextIndex)
	}

	/**
	 * override and provide own injector
	 */
	protected def Injector getGuiceInjector() {
		Guice.createInjector
	}

	private def initializeWithRepository(File repository, XtextIndexConfiguration configuration) {
		try {
			gitService.init(repository, configuration.repoUrl)
			indexFiller.fillWithFileRecursively(indexInstance, repository)
		} catch (Exception e) {
			logger.error('''Initialization based on repositor='«repository.name»' failed with exceptions.''', e)
		}
	}

	override run(XtextIndexConfiguration configuration, Environment environment) {
		guiceInjector.injectMembers(this)
		val repoLocationFile = new File(configuration.repoLocation)

		initializeWithRepository(repoLocationFile, configuration)

		environment.jersey.register(new Push => [
			callback = pushEventIndexCallback => [index = indexInstance]
		])
	}
}
