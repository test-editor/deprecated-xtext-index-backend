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
import com.google.inject.Injector
import io.dropwizard.setup.Bootstrap
import io.dropwizard.setup.Environment
import java.io.File
import java.util.List
import javax.inject.Inject
import org.eclipse.jgit.api.errors.GitAPIException
import org.eclipse.xtext.ISetup
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.slf4j.LoggerFactory
import org.testeditor.web.dropwizard.DropwizardApplication
import org.testeditor.web.xtext.index.persistence.GitService
import org.testeditor.web.xtext.index.resources.GlobalScopeResource
import org.testeditor.web.xtext.index.resources.bitbucket.Push
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionDeserializer
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionSerializer

abstract class XtextIndexApplication extends DropwizardApplication<XtextIndexConfiguration> {

	protected static val logger = LoggerFactory.getLogger(XtextIndexApplication)

	@Inject PushEventIndexUpdateCallback pushEventIndexCallback
	@Inject GitService gitService
	@Inject FileBasedXtextIndexFiller indexFiller

	private XtextIndex indexInstance

	override getName() {
		return "xtext-index-service"
	}

	override initialize(Bootstrap<XtextIndexConfiguration> bootstrap) {
		super.initialize(bootstrap)
		registerCustomEObjectSerializer(bootstrap)
		languageSetups.forEach[createInjectorAndDoEMFRegistration]
	}

	private def registerCustomEObjectSerializer(Bootstrap<XtextIndexConfiguration> bootstrap) {
		val customSerializerModule = new SimpleModule
		customSerializerModule.addSerializer(IEObjectDescription, new EObjectDescriptionSerializer)
		customSerializerModule.addDeserializer(IEObjectDescription, new EObjectDescriptionDeserializer)
		bootstrap.objectMapper.registerModule(customSerializerModule)
	}

	override run(XtextIndexConfiguration configuration, Environment environment) {
		super.run(configuration, environment)
		configureServices(configuration, environment)
	}

	abstract protected def Injector getGuiceInjector()

	abstract protected def List<ISetup> getLanguageSetups()

	private def XtextIndex getIndexInstance() {
		if (this.indexInstance === null) {
			this.indexInstance = guiceInjector.getInstance(XtextIndex)
		}
		return this.indexInstance
	}

	protected def IGlobalScopeProvider getGlobalScopeProvider(){
        return guiceInjector.getInstance(IGlobalScopeProvider)
    }

	/**
	 * Adds the Xtext servlet and configures a session handler.
	 */
	protected def void configureServices(XtextIndexConfiguration configuration, Environment environment) {
		try {
			gitService.init(new File(configuration.repoLocation), configuration.repoUrl)
			indexFiller.fillWithFileRecursively(getIndexInstance, new File(configuration.repoLocation))
		} catch (GitAPIException e) {
			logger.
				error('''Failed repo initialization with repoLocation='«configuration.repoLocation» and repoUrl='«configuration.repoUrl»'. ''',
					e)
		}
		environment.jersey.register(new Push => [
			callback = pushEventIndexCallback => [index = getIndexInstance]
		])
		environment.jersey.register(new GlobalScopeResource(globalScopeProvider, indexInstance))
	}

}
